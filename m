Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22D3C6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:31:07 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so286640935pfw.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 14:31:07 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id h2si24723233pgc.40.2017.01.25.14.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 14:31:06 -0800 (PST)
Subject: Re: ioremap_page_range: remapping of physical RAM ranges
References: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <072b4406-16ef-cdf6-e968-711a60ca9a3f@nvidia.com>
Date: Wed, 25 Jan 2017 14:27:27 -0800
MIME-Version: 1.0
In-Reply-To: <CADY3hbEy+oReL=DePFz5ZNsnvWpm55Q8=mRTxCGivSL64gAMMA@mail.gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "A. Samy" <f.fallen45@gmail.com>, linux-mm@kvack.org
Cc: zhongjiang@huawei.com

On 01/25/2017 11:55 AM, A. Samy wrote:
> Hi,
>
> Commit 3277953de2f31 un-exported ioremap_page_range(), what is an
> alternative method of remapping a physical ram range...  This function
> was very useful, examples here:
> https://github.com/asamy/ksm/blob/master/mm.c#L38 and here:
> https://github.com/asamy/ksm/blob/master/ksm.c#L410 etc...
>
> So, you're forcing me to either reimplement it on my own (which is
> merely copy-pasting the kernel function), unless you have a suggestion
> on what else to use (which I could never find other)?

Hi A. Samy,

I'm sorry this caught you by surprise, let's try get your use case covered.

My thinking on this was: the exported ioremap* family of functions was clearly intended to provide 
just what the name says: mapping of IO (non-RAM) memory. If normal RAM is to be re-mapped, then it 
should not be done "casually" in a driver, as a (possibly unintended) side effect of a function that 
implies otherwise. Either it should be done within the core mm code, or perhaps a new, better-named 
wrapper could be provided, for cases such as yours.

After a very quick peek at your github code, it seems that your mm_remap() routine already has some 
code in common with __ioremap_caller(), so I'm thinking that we could basically promote your 
mm_remap to the in-tree kernel and EXPORT it, and maybe factor out the common parts (or not--it's 
small, after all). Thoughts? If you like it, I'll put something together here.

thanks
john h

>
> Thanks,
>
> -- 
> asamy
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
