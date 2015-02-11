Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id B87116B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 00:34:47 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id z12so1162653lbi.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 21:34:46 -0800 (PST)
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id y9si13636515lbr.7.2015.02.10.21.34.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 21:34:45 -0800 (PST)
Received: by labpn19 with SMTP id pn19so1249076lab.4
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 21:34:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211034307.GA2932@kroah.com>
References: <20150203231211.486950145@linuxfoundation.org>
	<20150203231212.223123220@linuxfoundation.org>
	<CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
	<20150211034307.GA2932@kroah.com>
Date: Wed, 11 Feb 2015 09:34:44 +0400
Message-ID: <CALYGNiN6isfggY-kjWAgP1UtGyvKYN+BhWyuk9x6CF3wDe97HA@mail.gmail.com>
Subject: Re: [PATCH 3.18 04/57] vm: add VM_FAULT_SIGSEGV handling support
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>, Jan Engelhardt <jengelh@inai.de>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Feb 11, 2015 at 6:43 AM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Tue, Feb 10, 2015 at 12:22:41PM +0400, Konstantin Khlebnikov wrote:
>> I've found regression:
>>
>> [  257.139907] ================================================
>> [  257.139909] [ BUG: lock held when returning to user space! ]
>> [  257.139912] 3.18.6-debug+ #161 Tainted: G     U
>> [  257.139914] ------------------------------------------------
>> [  257.139916] python/22843 is leaving the kernel with locks still held!
>> [  257.139918] 1 lock held by python/22843:
>> [  257.139920]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8104e4c2>]
>> __do_page_fault+0x162/0x570
>>
>> upstream commit 7fb08eca45270d0ae86e1ad9d39c40b7a55d0190 must be backported too.
>
> Ah, nice, I missed that one.  How did you test this?

I've catched hang on mmap_sem in some python self-test inside exherbo chroot.
With that patch test has finished successfully.

It seems the only way to tigger this is stack-overflow: for now VM_FAULT_SIGSEGV
is returned only if kernel cannot add guard page when stack expands.

>
> thanks,
>
> greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
