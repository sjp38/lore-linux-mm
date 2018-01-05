Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A00B36B0502
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 19:07:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z1so1806325pfl.9
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 16:07:14 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g34si3040501pld.328.2018.01.04.16.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Jan 2018 16:07:13 -0800 (PST)
Date: Thu, 4 Jan 2018 16:07:07 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <20180105000707.GA22237@bombadil.infradead.org>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
 <20180104013807.GA31392@tardis>
 <be1abd24-56c8-45bc-fecc-3f0c5b978678@oracle.com>
 <64ca3929-4044-9393-a6ca-70c0a2589a35@oracle.com>
 <20180104214658.GA20740@bombadil.infradead.org>
 <3e4ea0b9-686f-7e36-d80c-8577401517e2@oracle.com>
 <20180104231307.GA794@bombadil.infradead.org>
 <20180104234732.GM9671@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104234732.GM9671@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Joe Perches <joe@perches.com>, Rao Shoaib <rao.shoaib@oracle.com>, Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, Jan 04, 2018 at 03:47:32PM -0800, Paul E. McKenney wrote:
> I was under the impression that typeof did not actually evaluate its
> argument, but rather only returned its type.  And there are a few macros
> with this pattern in mainline.
> 
> Or am I confused about what typeof does?

I think checkpatch is confused by the '*' in the typeof argument:

$ git diff |./scripts/checkpatch.pl --strict
CHECK: Macro argument reuse 'ptr' - possible side-effects?
#29: FILE: include/linux/rcupdate.h:896:
+#define kfree_rcu(ptr, rcu_head)                                        \
+	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))

If one removes the '*', the warning goes away.

I'm no perlista, but Joe, would this regexp modification make sense?

+++ b/scripts/checkpatch.pl
@@ -4957,7 +4957,7 @@ sub process {
                                next if ($arg =~ /\.\.\./);
                                next if ($arg =~ /^type$/i);
                                my $tmp_stmt = $define_stmt;
-                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
+                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\**\(*\s*$arg\s*\)*\b//g;
                                $tmp_stmt =~ s/\#+\s*$arg\b//g;
                                $tmp_stmt =~ s/\b$arg\s*\#\#//g;
                                my $use_cnt = $tmp_stmt =~ s/\b$arg\b//g;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
