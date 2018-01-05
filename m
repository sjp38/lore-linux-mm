Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF7CF6B0328
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 21:14:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id s24so3421964ioa.9
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 18:14:28 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t185si3510767iod.43.2018.01.04.18.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 18:14:27 -0800 (PST)
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
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
From: Rao Shoaib <rao.shoaib@oracle.com>
Message-ID: <d7a23585-826c-9042-b8f9-6bd5895cbf16@oracle.com>
Date: Thu, 4 Jan 2018 18:14:08 -0800
MIME-Version: 1.0
In-Reply-To: <20180105000707.GA22237@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Joe Perches <joe@perches.com>, Boqun Feng <boqun.feng@gmail.com>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org



On 01/04/2018 04:07 PM, Matthew Wilcox wrote:
> On Thu, Jan 04, 2018 at 03:47:32PM -0800, Paul E. McKenney wrote:
>> I was under the impression that typeof did not actually evaluate its
>> argument, but rather only returned its type.  And there are a few macros
>> with this pattern in mainline.
>>
>> Or am I confused about what typeof does?
> I think checkpatch is confused by the '*' in the typeof argument:
Yup.
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
>                                  next if ($arg =~ /\.\.\./);
>                                  next if ($arg =~ /^type$/i);
>                                  my $tmp_stmt = $define_stmt;
> -                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\s*$arg\s*\)*\b//g;
> +                               $tmp_stmt =~ s/\b(typeof|__typeof__|__builtin\w+|typecheck\s*\(\s*$Type\s*,|\#+)\s*\(*\**\(*\s*$arg\s*\)*\b//g;
>                                  $tmp_stmt =~ s/\#+\s*$arg\b//g;
>                                  $tmp_stmt =~ s/\b$arg\s*\#\#//g;
>                                  my $use_cnt = $tmp_stmt =~ s/\b$arg\b//g;
>
Thanks a lot for digging into this. I had to try several variations for 
the warning to go away and don't remember the reason for each change. I 
am not perl literate and the regular expression sacred me ;-).

Shoaib

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
