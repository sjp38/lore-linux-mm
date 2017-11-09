Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEAA6B02D4
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 09:48:38 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f27so1555902ote.16
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 06:48:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j64si1293831otj.411.2017.11.09.06.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 06:48:34 -0800 (PST)
Subject: Re: MPK: pkey_free and key reuse
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <48ac42c0-4c31-cef8-a75a-8f3beab7cc66@redhat.com>
Date: Thu, 9 Nov 2017 15:48:26 +0100
MIME-Version: 1.0
In-Reply-To: <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/08/2017 09:41 PM, Dave Hansen wrote:
> On 11/05/2017 02:35 AM, Florian Weimer wrote:
>> I don't think pkey_free, as it is implemented today, is very safe due to
>> key reuse by a subsequent pkey_alloc.A  I see two problems:
>>
>> (A) pkey_free allows reuse for they key while there are still mappings
>> that use it.
> 
> I don't agree with this assessment.  Is malloc() unsafe?  If someone
> free()s memory that is still in use, a subsequent malloc() would hand
> the address out again for reuse.

I think the disagreement is not about what is considered acceptable 
behavior as such, but what constitutes a??usea??.

And even if with concurrent use, the behavior can be well-defined.  We 
make sure that if munmap is called, we do not return before all threads 
have observed in principle that the page is gone (at considerable cost, 
of course, and in most cases, that is total overkill).

I'm pretty sure there is another key reuse scenario which does not even 
involve pkey_free, but I need to write a test first.

>> (B) If a key is reused, existing threads retain their access rights,
>> while there is an expectation that pkey_alloc denies access for the
>> threads except the current one.
> Where does this expectation come from?

For me, it was the access_rights argument to pkey_alloc.  What else 
would it do?  For the current thread, I can already set the rights with 
a PKRU write, so the existence of the syscall argument is puzzling.

> Using the malloc() analogy, we
> don't expect that free() in one thread actively takes away references to
> the memory held by other threads.

But malloc/free isn't expected to be a partial antidote to random 
pointer scribbling.

> We define free() as only being called on resources to which there are no
> active references.  If you free() things in use, bad things happen.
> pkey_free() is only to be called when there is nothing actively using
> the key.  If you pkey_free() an in-use key, bad things happen.

My impression was that MPK was intended as a fallback in case you did 
that, and unrelated code suddenly writes through a dangling pointer and 
accidentally hits the DAX-mapped persistent memory of the database.  To 
prevent that, the those pages are mapped write-disabled on all threads 
almost all the time, and only if the database needs to write something, 
it temporarily tweaks PKRU so that it gains access.  All that assumes 
that you can actually restrict all threads in the process, but with the 
current implementation, that's not true even if threads never touch keys 
they don't know.

I think we should either implement revoke on pkey_alloc, with a 
broadcast to all threads (the pkey_set race can be closed by having a 
vDSO for that an the revocation code can check %rip to see if the old 
PKRU value needs to be fixed up).  Or we add the two pkey_alloc flags I 
mentioned earlier.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
