Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B151440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:59:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g6so6028991pgn.11
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:59:59 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f19si6766953plr.246.2017.11.09.08.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 08:59:58 -0800 (PST)
Subject: Re: MPK: pkey_free and key reuse
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
 <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
 <48ac42c0-4c31-cef8-a75a-8f3beab7cc66@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <633b5b03-3481-0da2-9d6c-f5298902e36a@linux.intel.com>
Date: Thu, 9 Nov 2017 08:59:56 -0800
MIME-Version: 1.0
In-Reply-To: <48ac42c0-4c31-cef8-a75a-8f3beab7cc66@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/09/2017 06:48 AM, Florian Weimer wrote:
> On 11/08/2017 09:41 PM, Dave Hansen wrote:
>>> (B) If a key is reused, existing threads retain their access rights,
>>> while there is an expectation that pkey_alloc denies access for the
>>> threads except the current one.
>> Where does this expectation come from?
> 
> For me, it was the access_rights argument to pkey_alloc.A  What else
> would it do?A  For the current thread, I can already set the rights with
> a PKRU write, so the existence of the syscall argument is puzzling.

The manpage is pretty bare here.  But the thought was that, in most
cases, you will want to allocate a key and start using it immediately.
This was in response to some feedback on one of the earlier reviews of
the patch set.

>> Using the malloc() analogy, we
>> don't expect that free() in one thread actively takes away references to
>> the memory held by other threads.
> 
> But malloc/free isn't expected to be a partial antidote to random
> pointer scribbling.

Nor is protection keys intended to be an antidote for use-after-free.

> I think we should either implement revoke on pkey_alloc, with a
> broadcast to all threads (the pkey_set race can be closed by having a
> vDSO for that an the revocation code can check %rip to see if the old
> PKRU value needs to be fixed up).A  Or we add the two pkey_alloc flags I
> mentioned earlier.

That sounds awfully complicated to put in-kernel.  I'd be happy to
review the patches after you put them together once we see how it looks.

You basically want threads to broadcast their PKRU values at pkey_free()
time.  That's totally doable... in userspace.  You just need a mechanism
for each thread to periodically check if they need an update.  I don't
think we need kernel intervention and vDSO magic for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
