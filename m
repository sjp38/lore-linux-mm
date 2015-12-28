Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DB2E66B027F
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 17:21:10 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so93036955pac.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 14:21:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e65si10895581pfb.47.2015.12.28.14.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 14:21:10 -0800 (PST)
Date: Mon, 28 Dec 2015 14:21:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Message-Id: <20151228142108.fa679ebf9d3a91ad14924977@linux-foundation.org>
In-Reply-To: <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk

On Wed,  9 Dec 2015 12:19:37 +0900 Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> This patch extends existing "kernelcore" option and
> introduces kernelcore=mirror option. By specifying
> "mirror" instead of specifying the amount of memory,
> non-mirrored (non-reliable) region will be arranged
> into ZONE_MOVABLE.
> 
> v1 -> v2:
>  - Refine so that the following case also can be
>    handled properly:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>    (legend) M: mirrored  -: not mirrrored
> 
>  In this case, ZONE_NORMAL and ZONE_MOVABLE are
>  arranged like bellow:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>           |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>                 |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>    (legend) o: present  x: absent
> 
> v2 -> v3:
>  - change the option name from kernelcore=reliable
>    into kernelcore=mirror
>  - documentation fix so that users can understand
>    nn[KMS] and mirror are exclusive

My earlier concern with this approach is the assumption that *all* of
the mirrored memory will be used to kernelcore.  The user might want to
use half the machine's mirrored memory for kernelcore and half for
regular memory but cannot do so.

However I think what I'm seeing from the discussion is that in this
case, the user can alter the amount of mirrored memory via EFI to
achieve the same effect.

Is this correct?  If so, should we document this somewhere and provide
our users with instructions on how to make the required EFI changes? 
Or is this all so totally obvious to them that there is no need?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
