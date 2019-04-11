Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A613C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF6332183E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xMZ7xPWj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF6332183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70A486B026A; Wed, 10 Apr 2019 21:36:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E0526B026B; Wed, 10 Apr 2019 21:36:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9A36B026C; Wed, 10 Apr 2019 21:36:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7086B026A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x23so3702697qka.19
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=;
        b=OdGs6lJYb5d+JhP1da6H79yLw+LWJLa1kE8uJcU9iVXtWJ/u92fYv+2r4vOXihtdT0
         qaK3yCcanjBzsJ5vBoMaEDtk6kaFJl5RWZMN0Ds4dOoWFnb0jObc3V2bmNTdDKbfWaGc
         4bAm/Q+DIUKtiOtjAIH8LBKk71V8llHd57/p1ui7ciZHiMzSeJWKuAoardJTCabi+TlE
         s0NH3/bfdmwH0R0cUHulnOZ6R9Vx89ZttCt7ZoWI4tInuEZrevm37BJ+5Q7dI+5o6YX8
         EmCUEz89lVUVtvh2GTYDRNf1IZ8rmCM5FvfQgoSP2FGswruslR2XqQyUDfCpooPEhkzs
         tArg==
X-Gm-Message-State: APjAAAWvqj6zpsC3m4c9lYjcfRCVcXyTc14QcR4zH6V5PHzXirjfe+BG
	n0KCeJg6tjxYtjFg0RKheQ7pnZ/rtQnjhBREpKrtGzrVxziSWCtgfShOjMISFPo/uURCd3Bp7JA
	f9PiMZgFzRY9Kxrm86fuVdBal8BUjB2BiMcAYr4R5lIPPPi+bbR8EhTFte69hGGg=
X-Received: by 2002:a0c:9849:: with SMTP id e9mr37929122qvd.193.1554946607922;
        Wed, 10 Apr 2019 18:36:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynHN4XviMn1qUUS7z+csK/ojf73hasy2CZjP4uuyjhSm+r3eyqC62rDLJ1F8yEFWf9gJh3
X-Received: by 2002:a0c:9849:: with SMTP id e9mr37929037qvd.193.1554946606280;
        Wed, 10 Apr 2019 18:36:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946606; cv=none;
        d=google.com; s=arc-20160816;
        b=qajWa6MG+qQGGcgqzFG/1eHOlnt+erKd9Cif6mXiJ2wl4q1gs6/IODBQrk4rGNxJcx
         A/+VKKJtA/mQbvqgWApCDLU3tZUeek7YTbCUV0znZ+oY3yPcQ7e7QZMkcUHib0QDfiqJ
         XnFAg0EhAGBfGG/vTVPz7WH2uv495CL9U3B0bX8RicgJWG123VztUKndE/k3DrnCqI9D
         7HYVNevNjBmWKVmZgjc/iy5GxDOMbQpw83bl13HVhWnL0WIraRr8z69bbW8TjW7JRu9U
         bKwBy5YuIoS9tQZAzZLi4gAqdw7kiBm/NNrutvzdC61vhK+UhD1/BnyUJTPXWUKK9QiF
         6CvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=;
        b=ysnQNEPJuX+lhGsFbMLjAoGhb4z7RUAH4Z7TAQGCz6qdYfmQXB9vxGDXzkzHMJ6p6i
         TijrggSz4uv2+FN8qh8oyNgLScPYLBsPxeA0dWgGsbIY13ohEJ/DiIUx+JUeB2Gc+Ei/
         ZZLBLTOyRP4Ylg7xn787DEp6SI30yuui/dEv3FUuxhEWN/9QpsK77OpT47OZVeD07ayZ
         T8SvIysWWoVpbnkb7CG+MZnrBw/GK257mipMjk5krLForoJp46MYw6gZt+SY6MJrx+9w
         3T2cuV68WWMwfJZC0NlfhaykmjhQRl0/53cdqSYcx87z/tc3yO1Lg+Vwz6MFlGplI5q4
         JtAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xMZ7xPWj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id t38si11064651qta.332.2019.04.10.18.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=xMZ7xPWj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 03D32F012;
	Wed, 10 Apr 2019 21:36:46 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=; b=xMZ7xPWj
	7mQhlF/VPkLAxyqL7XOsxnorCyDQl73KjSwyAVsh5ljtaj3ewnGPFvRyV7aVqWfm
	iufdKzNzJgFcA7JsKo7oDyS2YS3QPbqqQeunpzG85iw0vw6CX1zRJ1RiJktH1xiv
	xbLioQBYt8moTj8o/o1q6XfvqoEUzCGO5c6E0FDxIVPq81fZQcDBDftC7UrixyBL
	uOzccN6FZP17IuGxTKhhv57tOq1AlC1tpP2qvRbDwbMLQ1w9KtJfxWxOuUj4gXBI
	Z3NwRxQ9YDtb2AelTURT36C6LEFTax7ejYkwT8cxv2mWCx1xh8BQ8Z8fPzcjGCN7
	GkyFXVt6iLLHKA==
X-ME-Sender: <xms:LZquXFZpISGqowbWDFHlIumPNOg_PiZSuHAagk9-EF5aJSBaBeKjAw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:LZquXAoTSnCr9NpJOBxKygcCwf2bJLKd_5jelK9Olcfim7oqaNcTgw>
    <xmx:LZquXC8EiFea-ZFGwkPlk-TsyL1j-oYYjVSV-f7p7G9ROEXF0bFwXg>
    <xmx:LZquXH8L_yRB8WH808LIsdG6xZpQYF-VfQ2S69DEhcahHnL03eN6hw>
    <xmx:LZquXBjbMrFQ5O4okV7GolFOEYvYGSKVWXWgoUnXhoABYQtLw9G5pQ>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id A6BA9E408B;
	Wed, 10 Apr 2019 21:36:36 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 08/15] tools/testing/slab: Add object migration test suite
Date: Thu, 11 Apr 2019 11:34:34 +1000
Message-Id: <20190411013441.5415-9-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We just added a module that enables testing the SLUB allocators ability
to defrag/shrink caches via movable objects.  Tests are better when they
are automated.

Add automated testing via a python script for SLUB movable objects.

Example output:

  $ cd path/to/linux/tools/testing/slab
  $ /slub_defrag.py
  Please run script as root

  $ sudo ./slub_defrag.py
  <test are quiet, no output on success>

  $ sudo ./slub_defrag.py --debug
  Loading module ...
  Slab cache smo_test created
  Objects per slab: 20
  Running sanity checks ...

  Running module stress test (see dmesg for additional test output) ...
  Removing module slub_defrag ...
  Loading module ...
  Slab cache smo_test created

  Running test non-movable ...
  testing slab 'smo_test' prior to enabling movable objects ...
  verified non-movable slabs are NOT shrinkable

  Running test movable ...
  testing slab 'smo_test' after enabling movable objects ...
  verified movable slabs are shrinkable

  Removing module slub_defrag ...

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/testing/slab/slub_defrag.c  |   1 +
 tools/testing/slab/slub_defrag.py | 451 ++++++++++++++++++++++++++++++
 2 files changed, 452 insertions(+)
 create mode 100755 tools/testing/slab/slub_defrag.py

diff --git a/tools/testing/slab/slub_defrag.c b/tools/testing/slab/slub_defrag.c
index 4a5c24394b96..8332e69ee868 100644
--- a/tools/testing/slab/slub_defrag.c
+++ b/tools/testing/slab/slub_defrag.c
@@ -337,6 +337,7 @@ static int smo_run_module_tests(int nr_objs, int keep)
 
 /*
  * struct functions() - Map command to a function pointer.
+ * If you update this please update the documentation in slub_defrag.py
  */
 struct functions {
 	char *fn_name;
diff --git a/tools/testing/slab/slub_defrag.py b/tools/testing/slab/slub_defrag.py
new file mode 100755
index 000000000000..41747c0db39b
--- /dev/null
+++ b/tools/testing/slab/slub_defrag.py
@@ -0,0 +1,451 @@
+#!/usr/bin/env python3
+# SPDX-License-Identifier: GPL-2.0
+
+import subprocess
+import sys
+from os import path
+
+# SLUB Movable Objects test suite.
+#
+# Requirements:
+#  - CONFIG_SLUB=y
+#  - CONFIG_SLUB_DEBUG=y
+#  - The slub_defrag module in this directory.
+
+# Test SMO using a kernel module that enables triggering arbitrary
+# kernel code from userspace via a debugfs file.
+#
+# Module code is in ./slub_defrag.c, basically the functionality is as
+# follows:
+#
+#  - Creates debugfs file /sys/kernel/debugfs/smo/callfn
+#  - Writes to 'callfn' are parsed as a command string and the function
+#    associated with command is called.
+#  - Defines 4 commands (all commands operate on smo_test cache):
+#     - 'test': Runs module stress tests.
+#     - 'alloc N': Allocates N slub objects
+#     - 'free N POS': Frees N objects starting at POS (see below)
+#     - 'enable': Enables SLUB Movable Objects
+#
+# The module maintains a list of allocated objects.  Allocation adds
+# objects to the tail of the list.  Free'ing frees from the head of the
+# list.  This has the effect of creating free slots in the slab.  For
+# finer grained control over where in the cache slots are free'd POS
+# (position) argument may be used.
+
+# The main() function is reasonably readable; the test suite does the
+# following:
+#
+# 1. Runs the module stress tests.
+# 2. Tests the cache without movable objects enabled.
+#    - Creates multiple partial slabs as explained above.
+#    - Verifies that partial slabs are _not_ removed by shrink (see below).
+# 3. Tests the cache with movable objects enabled.
+#    - Creates multiple partial slabs as explained above.
+#    - Verifies that partial slabs _are_ removed by shrink (see below).
+
+# The sysfs file /sys/kernel/slab/<cache>/shrink enables calling the
+# function kmem_cache_shrink() (see mm/slab_common.c and mm/slub.cc).
+# Shrinking a cache attempts to consolidate all partial slabs by moving
+# objects if object migration is enable for the cache, otherwise
+# shrinking a cache simply re-orders the partial list so as most densely
+# populated slab are at the head of the list.
+
+# Enable/disable debugging output (also enabled via -d | --debug).
+debug = False
+
+# Used in debug messages and when running `insmod`.
+MODULE_NAME = "slub_defrag"
+
+# Slab cache created by the test module.
+CACHE_NAME = "smo_test"
+
+# Set by get_slab_config()
+objects_per_slab = 0
+pages_per_slab = 0
+debugfs_mounted = False         # Set to true if we mount debugfs.
+
+
+def eprint(*args, **kwargs):
+    print(*args, file=sys.stderr, **kwargs)
+
+
+def dprint(*args, **kwargs):
+    if debug:
+        print(*args, file=sys.stderr, **kwargs)
+
+
+def run_shell(cmd):
+    return subprocess.call([cmd], shell=True)
+
+
+def run_shell_get_stdout(cmd):
+    return subprocess.check_output([cmd], shell=True)
+
+
+def assert_root():
+    user = run_shell_get_stdout('whoami')
+    if user != b'root\n':
+        eprint("Please run script as root")
+        sys.exit(1)
+
+
+def mount_debugfs():
+    mounted = False
+
+    # Check if debugfs is mounted at a known mount point.
+    ret = run_shell('mount -l | grep /sys/kernel/debug > /dev/null 2>&1')
+    if ret != 0:
+        run_shell('mount -t debugfs none /sys/kernel/debug/')
+        mounted = True
+        dprint("Mounted debugfs on /sys/kernel/debug")
+
+    return mounted
+
+
+def umount_debugfs():
+    dprint("Un-mounting debugfs")
+    run_shell('umount /sys/kernel/debug')
+
+
+def load_module():
+    """Loads the test module.
+
+    We need a clean slab state to start with so module must
+    be loaded by the test suite.
+    """
+    ret = run_shell('lsmod | grep %s > /dev/null' % MODULE_NAME)
+    if ret == 0:
+        eprint("Please unload slub_defrag module before running test suite")
+        return -1
+
+    dprint('Loading module ...')
+    ret = run_shell('insmod %s.ko' % MODULE_NAME)
+    if ret != 0:                # ret==1 on error
+        return -1
+
+    dprint("Slab cache %s created" % CACHE_NAME)
+    return 0
+
+
+def unload_module():
+    ret = run_shell('lsmod | grep %s > /dev/null' % MODULE_NAME)
+    if ret == 0:
+        dprint('Removing module %s ...' % MODULE_NAME)
+        run_shell('rmmod %s > /dev/null 2>&1' % MODULE_NAME)
+
+
+def get_sysfs_value(filename):
+    """
+    Parse slab sysfs files (single line: '20 N0=20')
+    """
+    path = '/sys/kernel/slab/smo_test/%s' % filename
+    f = open(path, "r")
+    s = f.readline()
+    tokens = s.split(" ")
+
+    return int(tokens[0])
+
+
+def get_nr_objects_active():
+    return get_sysfs_value('objects')
+
+
+def get_nr_objects_total():
+    return get_sysfs_value('total_objects')
+
+
+def get_nr_slabs_total():
+    return get_sysfs_value('slabs')
+
+
+def get_nr_slabs_partial():
+    return get_sysfs_value('partial')
+
+
+def get_nr_slabs_full():
+    return get_nr_slabs_total() - get_nr_slabs_partial()
+
+
+def get_slab_config():
+    """Get relevant information from sysfs."""
+    global objects_per_slab
+
+    objects_per_slab = get_sysfs_value('objs_per_slab')
+    if objects_per_slab < 0:
+        return -1
+
+    dprint("Objects per slab: %d" % objects_per_slab)
+    return 0
+
+
+def verify_state(nr_objects_active, nr_objects_total,
+                 nr_slabs_partial, nr_slabs_full, nr_slabs_total, msg=''):
+    err = 0
+    got_nr_objects_active = get_nr_objects_active()
+    got_nr_objects_total = get_nr_objects_total()
+    got_nr_slabs_partial = get_nr_slabs_partial()
+    got_nr_slabs_full = get_nr_slabs_full()
+    got_nr_slabs_total = get_nr_slabs_total()
+
+    if got_nr_objects_active != nr_objects_active:
+        err = -1
+
+    if got_nr_objects_total != nr_objects_total:
+        err = -2
+
+    if got_nr_slabs_partial != nr_slabs_partial:
+        err = -3
+
+    if got_nr_slabs_full != nr_slabs_full:
+        err = -4
+
+    if got_nr_slabs_total != nr_slabs_total:
+        err = -5
+
+    if err != 0:
+        dprint("Verify state: %s" % msg)
+        dprint("  what\t\t\twant\tgot")
+        dprint("-----------------------------------------")
+        dprint("  %s\t%d\t%d" % ('nr_objects_active', nr_objects_active, got_nr_objects_active))
+        dprint("  %s\t%d\t%d" % ('nr_objects_total', nr_objects_total, got_nr_objects_total))
+        dprint("  %s\t%d\t%d" % ('nr_slabs_partial', nr_slabs_partial, got_nr_slabs_partial))
+        dprint("  %s\t\t%d\t%d" % ('nr_slabs_full', nr_slabs_full, got_nr_slabs_full))
+        dprint("  %s\t%d\t%d\n" % ('nr_slabs_total', nr_slabs_total, got_nr_slabs_total))
+
+    return err
+
+
+def exec_via_sysfs(command):
+        ret = run_shell('echo %s > /sys/kernel/debug/smo/callfn' % command)
+        if ret != 0:
+            eprint("Failed to echo command to sysfs: %s" % command)
+
+        return ret
+
+
+def enable_movable_objects():
+    return exec_via_sysfs('enable')
+
+
+def alloc(n):
+    exec_via_sysfs("alloc %d" % n)
+
+
+def free(n, pos = 0):
+    exec_via_sysfs('free %d %d' % (n, pos))
+
+
+def shrink():
+    ret = run_shell('slabinfo smo_test -s')
+    if ret != 0:
+            eprint("Failed to execute slabinfo -s")
+
+
+def sanity_checks():
+    # Verify everything is 0 to start with.
+    return verify_state(0, 0, 0, 0, 0, "sanity check")
+
+
+def test_non_movable():
+    one_over = objects_per_slab + 1
+
+    dprint("testing slab 'smo_test' prior to enabling movable objects ...")
+
+    alloc(one_over)
+
+    objects_active = one_over
+    objects_total = objects_per_slab * 2
+    slabs_partial = 1
+    slabs_full = 1
+    slabs_total = 2
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "non-movable: initial allocation")
+    if ret != 0:
+        eprint("test_non_movable: failed to verify initial state")
+        return -1
+
+    # Free object from first slot of first slab.
+    free(1)
+    objects_active = one_over - 1
+    objects_total = objects_per_slab * 2
+    slabs_partial = 2
+    slabs_full = 0
+    slabs_total = 2
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "non-movable: after free")
+    if ret != 0:
+        eprint("test_non_movable: failed to verify after free")
+        return -1
+
+    # Non-movable cache, shrink should have no effect.
+    shrink()
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "non-movable: after shrink")
+    if ret != 0:
+        eprint("test_non_movable: failed to verify after shrink")
+        return -1
+
+    # Cleanup
+    free(objects_per_slab)
+    shrink()
+
+    dprint("verified non-movable slabs are NOT shrinkable")
+    return 0
+
+
+def test_movable():
+    one_over = objects_per_slab + 1
+
+    dprint("testing slab 'smo_test' after enabling movable objects ...")
+
+    alloc(one_over)
+
+    objects_active = one_over
+    objects_total = objects_per_slab * 2
+    slabs_partial = 1
+    slabs_full = 1
+    slabs_total = 2
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "movable: initial allocation")
+    if ret != 0:
+        eprint("test_movable: failed to verify initial state")
+        return -1
+
+    # Free object from first slot of first slab.
+    free(1)
+    objects_active = one_over - 1
+    objects_total = objects_per_slab * 2
+    slabs_partial = 2
+    slabs_full = 0
+    slabs_total = 2
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "movable: after free")
+    if ret != 0:
+        eprint("test_movable: failed to verify after free")
+        return -1
+
+    # movable cache, shrink should move objects and free slab.
+    shrink()
+    objects_active = one_over - 1
+    objects_total = objects_per_slab * 1
+    slabs_partial = 0
+    slabs_full = 1
+    slabs_total = 1
+    ret = verify_state(objects_active, objects_total,
+                       slabs_partial, slabs_full, slabs_total,
+                       "movable: after shrink")
+    if ret != 0:
+        eprint("test_movable: failed to verify after shrink")
+        return -1
+
+    # Cleanup
+    free(objects_per_slab)
+    shrink()
+
+    dprint("verified movable slabs are shrinkable")
+    return 0
+
+
+def dprint_start_test(test):
+    dprint("Running %s ..." % test)
+
+
+def dprint_done():
+    dprint("")
+
+
+def run_test(fn, desc):
+    dprint_start_test(desc)
+    ret = fn()
+    if ret < 0:
+        fail_test(desc)
+    dprint_done()
+
+
+# Load and unload the module for this test to ensure clean state.
+def run_module_stress_test():
+    dprint("Running module stress test (see dmesg for additional test output) ...")
+
+    unload_module()
+    ret = load_module()
+    if ret < 0:
+        cleanup_and_exit(ret)
+
+    exec_via_sysfs("test");
+
+    unload_module()
+
+    dprint()
+
+
+def fail_test(msg):
+    eprint("\nFAIL: test failed: '%s' ... aborting\n" % msg)
+    cleanup_and_exit(1)
+
+
+def display_help():
+    print("Usage: %s [OPTIONS]\n" % path.basename(sys.argv[0]))
+    print("\tRuns defrag test suite (a.k.a. SLUB Movable Objects)\n")
+    print("OPTIONS:")
+    print("\t-d | --debug       Enable verbose debug output")
+    print("\t-h | --help        Print this help and exit")
+
+
+def cleanup_and_exit(return_code):
+    global debugfs_mounted
+
+    if debugfs_mounted == True:
+        umount_debugfs()
+
+    unload_module()
+
+    sys.exit(return_code)
+
+
+def main():
+    global debug
+
+    if len(sys.argv) > 1:
+        if sys.argv[1] == '-h' or sys.argv[1] == '--help':
+            display_help()
+            sys.exit(0)
+
+        if sys.argv[1] == '-d' or sys.argv[1] == '--debug':
+            debug = True
+
+    assert_root()
+
+    # Use cleanup_and_exit() instead of sys.exit() after mounting debugfs.
+    debugfs_mounted = mount_debugfs()
+
+    # Loads and unloads the module.
+    run_module_stress_test()
+
+    ret = load_module()
+    if (ret < 0):
+        cleanup_and_exit(ret)
+
+    ret = get_slab_config()
+    if (ret != 0):
+        fail_test("get slab config details")
+
+    run_test(sanity_checks, "sanity checks")
+
+    run_test(test_non_movable, "test non-movable")
+
+    ret = enable_movable_objects()
+    if (ret != 0):
+        fail_test("enable movable objects")
+
+    run_test(test_movable, "test movable")
+
+    cleanup_and_exit(0)
+
+if __name__== "__main__":
+  main()
-- 
2.21.0

