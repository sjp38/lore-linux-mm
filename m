Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 875196B45B9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 06:39:22 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id q188-v6so253157ljq.22
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:39:22 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id o9-v6si350803lfk.172.2018.08.28.03.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 03:39:20 -0700 (PDT)
From: Vincent Whitchurch <vincent.whitchurch@axis.com>
Subject: [PATCH 2/2] scripts: add kmemleak2pprof.py for slab usage analysis
Date: Tue, 28 Aug 2018 12:39:14 +0200
Message-Id: <20180828103914.30434-2-vincent.whitchurch@axis.com>
In-Reply-To: <20180828103914.30434-1-vincent.whitchurch@axis.com>
References: <20180828103914.30434-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

Add a script which converts /sys/kernel/debug/kmemleak_all to the pprof
format, which can be used for analysing memory usage.  See
https://github.com/google/pprof.

 $ ./kmemleak2pprof.py kmemleak_all
 $ pprof -text -ignore free_area_init_node -compact_labels -nodecount 10 prof
 Showing nodes accounting for 4.85MB, 34.05% of 14.23MB total
 Dropped 3989 nodes (cum <= 0.07MB)
 Showing top 10 nodes out of 190
       flat  flat%   sum%        cum   cum%
     1.39MB  9.78%  9.78%     1.61MB 11.29%  new_inode_pseudo+0x8/0x4c
     0.75MB  5.27% 15.04%     0.75MB  5.27%  alloc_large_system_hash+0x19c/0x2b8
     0.73MB  5.12% 20.17%     0.86MB  6.07%  kernfs_new_node+0x30/0x50
     0.66MB  4.62% 24.79%     0.66MB  4.62%  __vmalloc_node.constprop.9+0x48/0x50
     0.61MB  4.28% 29.06%     0.61MB  4.28%  d_alloc+0x10/0x78
     0.22MB  1.52% 30.58%     0.22MB  1.52%  alloc_inode+0x1c/0xa4
     0.18MB  1.28% 31.86%     0.20MB  1.42%  _do_fork+0xb0/0x41c
     0.13MB  0.88% 32.74%     0.13MB  0.88%  early_trace_init+0x16c/0x374
     0.09MB  0.66% 33.40%     0.17MB  1.17%  inet_init+0x128/0x24c
     0.09MB  0.65% 34.05%     0.09MB  0.65%  __kernfs_new_node+0x34/0x1a8

Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
---
 scripts/kmemleak2pprof.py | 164 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 164 insertions(+)
 create mode 100755 scripts/kmemleak2pprof.py

diff --git a/scripts/kmemleak2pprof.py b/scripts/kmemleak2pprof.py
new file mode 100755
index 000000000000..1295d3ca9a9d
--- /dev/null
+++ b/scripts/kmemleak2pprof.py
@@ -0,0 +1,164 @@
+#!/usr/bin/env python3
+# SPDX-License-Identifier: GPL-2.0
+#
+# Copyright (C) 2018 Axis Communications AB
+#
+# Converts /sys/kernel/debug/kmemleak_all to the pprof format, see
+# https://github.com/google/pprof.
+#
+# profile_pb2.py can be generated with the following commands.  protoc is
+# packaged as protobuf-compiler in Debian:
+#
+#  wget https://raw.githubusercontent.com/google/pprof/master/proto/profile.proto
+#  protoc -I. --python_out=. profile.proto
+
+import argparse
+
+from collections import defaultdict
+
+import profile_pb2
+
+
+# object 0xee0243b0 (size 464):
+#   comm "swapper/0", pid 0, jiffies 4294937296
+#     [<80220673>] alloc_inode+0x13/0x60
+#     [<80221cc5>] new_inode_pseudo+0xd/0x38
+#     [<802568a3>] proc_setup_thread_self+0x37/0xc4
+#     [<8020e8c1>] mount_ns+0x55/0x94
+#     [<8024f2e1>] proc_mount+0x45/0x48
+#     [<8020ee9b>] mount_fs+0x1f/0x104
+#     [<80224785>] vfs_kern_mount.part.3+0x35/0xbc
+#     [<80224833>] kern_mount_data+0x17/0x2c
+#     [<8024f44b>] pid_ns_prepare_proc+0x13/0x24
+#     [<8012ed0d>] alloc_pid+0x309/0x338
+#     [<80118e2b>] copy_process.part.5+0xa2b/0x1308
+#     [<80119807>] _do_fork+0x77/0x2f0
+#     [<80119abf>] kernel_thread+0x23/0x28
+#     [<8053517f>] rest_init+0x27/0xb4
+#     [<80900afb>] start_kernel+0x369/0x372
+#     [<0000807b>] 0x807b
+class KmemleakAll(object):
+    def __init__(self):
+        pass
+
+    def analyze(self, f):
+        allocs = defaultdict(int)
+        stack = []
+        size = 0
+
+        while True:
+            line = f.readline()
+            if not line:
+                break
+
+            line = line.strip()
+
+            if line.startswith('['):
+                # (null) is in the address part so later parsing steps fail.
+                # Don't bother fixing it up since it's clearly bogus.
+                if '(null)' in line:
+                    continue
+
+                stack.append(line)
+                continue
+            elif line.startswith('comm'):
+                continue
+
+            if size:
+                allocs[(tuple(stack), size)] += 1
+                size = 0
+
+            stack = []
+            size = int(line.split('(size ')[1].strip('):'))
+
+        return sorted(allocs.items(), key=lambda x: x[0][1] * x[1], reverse=True)
+
+
+class ProfileWriter(object):
+    def __init__(self, allocs):
+        self.profile = profile_pb2.Profile()
+        self.strings = ['']
+        self.allocs = allocs
+        self.locations = {}
+        self.functions = {}
+
+    def stridx(self, s):
+        try:
+            idx = self.strings.index(s)
+        except ValueError:
+            idx = len(self.strings)
+            self.strings.append(s)
+
+        return idx
+
+    def get_function_id(self, funcname, filename):
+        try:
+            return self.functions[(funcname, filename)].id
+        except KeyError:
+            pass
+
+        function = self.profile.function.add()
+        function.id = len(self.functions) + 1
+        function.name = self.stridx(funcname)
+        function.filename = self.stridx(filename)
+
+        self.functions[(funcname, filename)] = function
+
+        return function.id
+
+    def get_location_id(self, addr):
+        if addr.startswith('['):
+            _, func = addr.split(' ', maxsplit=1)
+
+        try:
+            return self.locations[addr].id
+        except KeyError:
+            pass
+
+        location = self.profile.location.add()
+        location.id = len(self.locations) + 1
+
+        # We don't have access to the file or line information.
+        locline = location.line.add()
+        locline.function_id = self.get_function_id(func, 'dummy.c')
+
+        self.locations[addr] = location
+
+        return location.id
+
+    def write(self, fn):
+        valuetype = self.profile.sample_type.add()
+        valuetype.type = self.stridx('slab')
+        valuetype.unit = self.stridx('bytes')
+
+        for i, alloc in enumerate(self.allocs):
+            stacksize, count = alloc
+            stack, size = stacksize
+
+            for instance in range(count):
+                sample = self.profile.sample.add()
+                sample.value.append(size)
+
+                for addr in stack:
+                    sample.location_id.append(self.get_location_id(addr))
+
+        self.profile.string_table.extend(self.strings)
+
+        with open(fn, 'wb') as f:
+            f.write(self.profile.SerializeToString())
+
+
+def main():
+    parser = argparse.ArgumentParser()
+    parser.add_argument('--output', default='prof')
+    parser.add_argument('data')
+    args = parser.parse_args()
+
+    with open(args.data) as f:
+        allocs = KmemleakAll().analyze(f)
+
+    ProfileWriter(allocs).write(args.output)
+
+
+if __name__ == '__main__':
+    main()
-- 
2.11.0
