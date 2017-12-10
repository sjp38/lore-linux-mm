Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBD826B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 01:42:28 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id s12so8364223otc.5
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 22:42:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h14si3946618otd.133.2017.12.09.22.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Dec 2017 22:42:24 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
Date: Sun, 10 Dec 2017 07:42:21 +0100
MIME-Version: 1.0
In-Reply-To: <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/10/2017 01:17 AM, Dave Hansen wrote:
> On 12/09/2017 01:16 PM, Florian Weimer wrote:
>> The attached patch addresses a problem with the current x86 pkey
>> implementation, which makes default-readable pkeys unusable from signal
>> handlers because the default init_pkru value blocks access.
> 
> Thanks for looking into this!
> 
> What do you mean by "default-readable pkeys"?
> 
> I think you mean that, for any data that needs to be accessed to enter a
> signal handler, it must be set to pkey=0 with the current
> implementation.  All other keys are inaccessible when entering a signal
> handler because the "init" value disables access.

Right, and for keys which are readable (but not writable) most of the 
time, so that date is readable, this breaks things.

> My only nit with this is whether it is the *right* interface.  The
> signal vs. XSAVE state thing is pretty x86 specific and I doubt that
> this will be the last feature that we encounter that needs special
> signal behavior.

The interface is not specific to XSAVE.  To generic code, only the two 
signal mask manipulation functions are exposed.  And I expect that we're 
going to need that for other (non-x86) implementations because they will 
have the same issue because the signal handler behavior will be identical.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
