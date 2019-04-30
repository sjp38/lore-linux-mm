Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74B36C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C48921707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ASlhx7fp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C48921707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F00A6B000A; Mon, 29 Apr 2019 23:09:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A08F6B0278; Mon, 29 Apr 2019 23:09:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61ADD6B0279; Mon, 29 Apr 2019 23:09:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 425AA6B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:09:48 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 144so10658995qkf.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:09:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=;
        b=TNKDdc3S1GoziLR7/byPvML87T5VizlolAZNpQQ1RVO1g3+OxRgI59uns8yeMclZ5i
         Mg2nnwMHUvuQBWUT8vIexQjohlWC/56KJfnk07buBxuY6+aTjtDPahrOGJJ3tpsUm4Hp
         cbUmwmCcrX7Z5ps9I4MtYekguV2rN9P2pUy6vIE4CXdd7e6a0AVDC4YNF0eRUI5GXvH8
         hPy0DiZdP4l0ef+L9SkfgD7tN4YWvXq+Ctg4hnnazolCgQOvu1IgolZ9kLrPPYs5YsVt
         gqdEQpuCrlhFO2Iu1zFynHPi+zOAdYdklJvnbOBACWjOdkKxkz2tFt7kkfTmUyV5JY3/
         Qppg==
X-Gm-Message-State: APjAAAUS2unanL/m8d1rSf1k6aZD5L2etLd6J0WQ1Yq4QZxG7RKwURb1
	OfY7Y6Lp7fLO8ucBmyvS4XU9e8igvYO0I7cl4b6oU2Yy3d8apA9k9Y4WHKk/gmw0B6VE/T45XFI
	XxKMZ+xpWPI6Dac0YAikeJXCXWj/7BqrYArtW5uSO1T9BCNWlhmvmr7K5GnKa5qc=
X-Received: by 2002:a0c:9568:: with SMTP id m37mr19956231qvm.154.1556593787979;
        Mon, 29 Apr 2019 20:09:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLJLNAJ+ydnnKyb+gDwQLATVCudhFw+2sT0+f8R4N2t1mzNNUIjieArFSIoLQ2ZQmO70vi
X-Received: by 2002:a0c:9568:: with SMTP id m37mr19956147qvm.154.1556593785862;
        Mon, 29 Apr 2019 20:09:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593785; cv=none;
        d=google.com; s=arc-20160816;
        b=mH/pYW2gly+9DMegvDKxSyrxhP2+bSsdALXXDcpdhd60SyBwdbh28bnhAFOCqk732r
         5fq+IkYPYeD04lVWjs4BuSrfSzgKyDGU5TBeZUYAG/1tQDLcwKGmzVEyrj3Co/nHsyUM
         W72OmOeo7MV5bQr3w5Ho/6uNgmBh1ozLpf/QUDPe6gaS7PJGxxo+Ss+OVHgKhhPuIQ4a
         adByf5bRiZ8t0TE2LPT/5zoOgwyXXibi8OlCyBAB5adgaBCfMPpF5Xvkk2edY0SVGgEt
         ROz4Wo+hzapC8iEqVH3mtR3vbbyrNBUg+pwtzcGxVKRaCXuO1GGHhROR7pwLo2sBzGBl
         dWFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=;
        b=RkZDFYYugKL5x937s9pUWOgvgdH2JNajxI2pP4O/O47SFVZn0uO8S99XkHw59Pi7J5
         nF4rJ3zLhh+hetsRHtDsGQaTCba4OiubUWBCzjKGrVnrCOQy9meFAtbtkNrsgXHEzbSe
         LAvc8FgNKYzPu15Yp+4vB8SnPKU8NV0u4r1W26vziLpOP5g/bivdiXvRqqtv+0aAP4TA
         2vOGGNaYjjfvhJdMe5pXTJYCs1gZDV7lS2BESLZx9Tnq8AKKgyaVhxPE+0f1NIDcMfID
         tb9Z40zmlpJdbqXflZD7G30AiExiOn1LmyRq4gFHK3/qM9d7uZn2+v0izoNIjU66tI9P
         K1mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ASlhx7fp;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id c3si7006878qvu.149.2019.04.29.20.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:09:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ASlhx7fp;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 903B91392C;
	Mon, 29 Apr 2019 23:09:45 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:09:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=uFjBqY0LQHef1Kn1ZeUrrNjMW5b2u14kh3M2b0Ph/vA=; b=ASlhx7fp
	vSJyjBUzrvLn0cirv+vvTDmjhZccvtcSlfRFDcSnSHeGjKCI0S5lr7omxFjSVUrV
	4ZagTm3higSZaQlUmOBeUW6A5IdlC6mNtE2nthdgDgX2z7vuQAUnfdaWzVa874Zg
	8F26WyEnu500/au2vfpVoKsTREDEQ//GF9nRaop4DR1mY8OUeAl0ACppZui0cona
	sgQYqeLW6GPjNFxDmmMA99becdpkfldHTOPOtnl7SD28nA/jHoic/ygyu1zopTWy
	19538xVI6g1qUEw4B/pBZaS6LP2HHYQSce/ifdOC9VbjliguMoSoOPsH6KOWfz+p
	zSw0cz9c0D1t1g==
X-ME-Sender: <xms:ebzHXGYA-aTJRduwqy3aQ8a68946nwMb4lchwP5uot6XRKkbYKb-gQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeej
X-ME-Proxy: <xmx:ebzHXI9mEGbQCImOhuxjixhPQZIWNjqzlCBtw-1zcAlEP5tSVNqTbg>
    <xmx:ebzHXHZ1dG50ruQXdwGQnaMfB5JjQvVpcyagYtBQK9vtIl3ZvG9kcw>
    <xmx:ebzHXIPVscceppEqJJAfvCo2LBRdi11mVclmedpd6yahhe9XZCet-w>
    <xmx:ebzHXJpHkV9c3i-e6HY2-9ndO-7cUonR0xS4QFMer9eLxjMknNHlIA>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id B98CF103C9;
	Mon, 29 Apr 2019 23:09:37 -0400 (EDT)
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
Subject: [RFC PATCH v4 08/15] tools/testing/slab: Add object migration test suite
Date: Tue, 30 Apr 2019 13:07:39 +1000
Message-Id: <20190430030746.26102-9-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
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

