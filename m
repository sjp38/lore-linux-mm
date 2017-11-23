Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCA06B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 16:43:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c83so17854705pfj.11
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 13:43:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s59si11552564plb.276.2017.11.23.13.43.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 13:43:48 -0800 (PST)
Subject: Re: MPK: removing a pkey
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <8741e4d6-6ac0-9c07-99f3-95d8d04940b4@suse.cz>
 <813f9736-36dd-b2e5-c850-9f2d5f94514a@redhat.com>
 <f42fe774-bdcc-a509-bb7f-fe709fd28fcb@linux.intel.com>
 <9ec19ff3-86f6-7cfe-1a07-1ab1c5d9882c@redhat.com>
 <d98eb4b8-6e59-513d-fdf8-3395485cb851@linux.intel.com>
 <de93997a-7802-96cf-62e2-e59416e745ca@suse.cz>
 <17831167-7142-d42a-c7a0-59bdc8bbb786@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2d12777f-615a-8101-2156-cf861ec13aa7@suse.cz>
Date: Thu, 23 Nov 2017 22:42:20 +0100
MIME-Version: 1.0
In-Reply-To: <17831167-7142-d42a-c7a0-59bdc8bbb786@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/23/2017 04:00 PM, Dave Hansen wrote:
> On 11/23/2017 12:11 AM, Vlastimil Babka wrote:
>>> No, the default is clearly 0 and documented to be so.  The PROT_EXEC
>>> emulation one should be inaccessible in all the APIs so does not even
>>> show up as *being* a key in the API.  The fact that it's implemented
>>> with pkeys should be pretty immaterial other than the fact that you
>>> can't touch the high bits in PKRU.
>> So, just to be sure, if we call pkey_mprotect() with 0, will it blindly
>> set 0, or the result of arch_override_mprotect_pkey() (thus equivalent
>> to call with -1) ? I assume the latter?
> 
> It's supposed to set 0.
> 
> -1 was, as far as I remember, an internal-to-the-kernel-only thing to
> tell us that a key came from *mprotect()* instead of pkey_mprotect().

So, pkey_mprotect(..., 0) will set it to 0, regardless of PROT_EXEC.
pkey_mprotect(..., -1) or mprotect() will set it to 0-or-PROT_EXEC-pkey.

Can't shake the feeling that it's somewhat weird, but I guess it's
flexible at least. So just has to be well documented.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
