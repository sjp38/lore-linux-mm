Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F68A280267
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 01:46:17 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id i66so2977674itf.0
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 22:46:17 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0137.hostedemail.com. [216.40.44.137])
        by mx.google.com with ESMTPS id 65si3876500ioe.102.2018.01.04.22.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 22:46:16 -0800 (PST)
Message-ID: <1515134773.21222.13.camel@perches.com>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
From: Joe Perches <joe@perches.com>
Date: Thu, 04 Jan 2018 22:46:13 -0800
In-Reply-To: <20180105000707.GA22237@bombadil.infradead.org>
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
	 <20180105000707.GA22237@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Rao Shoaib <rao.shoaib@oracle.com>, Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, 2018-01-04 at 16:07 -0800, Matthew Wilcox wrote:
> On Thu, Jan 04, 2018 at 03:47:32PM -0800, Paul E. McKenney wrote:
> > I was under the impression that typeof did not actually evaluate its
> > argument, but rather only returned its type.  And there are a few macros
> > with this pattern in mainline.
> > 
> > Or am I confused about what typeof does?
> 
> I think checkpatch is confused by the '*' in the typeof argument:
> 
> $ git diff |./scripts/checkpatch.pl --strict
> CHECK: Macro argument reuse 'ptr' - possible side-effects?
> #29: FILE: include/linux/rcupdate.h:896:
> +#define kfree_rcu(ptr, rcu_head)                                        \
> +	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> 
> If one removes the '*', the warning goes away.
> 
> I'm no perlista, but Joe, would this regexp modification make sense?
> 
> +++ b/scripts/checkpatch.pl
> @@ -4957,7 +4957,7 @@ sub process {
>                                 next if ($arg =~ /\.\.\./);
>                                 next if ($arg =~ /^type$/i);
>                                 my $tmp_stmt = $define_stmt;
> -                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
> +                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\**\(*\s*$arg\s*\)*\b//g;

I supposed ideally it'd be more like

$tmp_stmt =~ s/\b(?:typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*(?:\s*\*\s*)*\s*\(*\s*$arg\s*\)*\b//g;

Adding ?: at the start to not capture and
(?:\s*\*\s*)* for any number of * with any
surrounding spacings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
