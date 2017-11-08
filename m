Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD00B44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 15:41:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 15so3679302pgc.16
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 12:41:32 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x23si4557561pgc.683.2017.11.08.12.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 12:41:31 -0800 (PST)
Subject: Re: MPK: pkey_free and key reuse
References: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e7d1e622-bbac-2750-2895-cc151458ff2f@linux.intel.com>
Date: Wed, 8 Nov 2017 12:41:30 -0800
MIME-Version: 1.0
In-Reply-To: <0f006ef4-a7b5-c0cf-5f58-d0fd1f911a54@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On 11/05/2017 02:35 AM, Florian Weimer wrote:
> I don't think pkey_free, as it is implemented today, is very safe due to
> key reuse by a subsequent pkey_alloc.A  I see two problems:
> 
> (A) pkey_free allows reuse for they key while there are still mappings
> that use it.

I don't agree with this assessment.  Is malloc() unsafe?  If someone
free()s memory that is still in use, a subsequent malloc() would hand
the address out again for reuse.

> (B) If a key is reused, existing threads retain their access rights,
> while there is an expectation that pkey_alloc denies access for the
> threads except the current one.
Where does this expectation come from?  Using the malloc() analogy, we
don't expect that free() in one thread actively takes away references to
the memory held by other threads.

We define free() as only being called on resources to which there are no
active references.  If you free() things in use, bad things happen.
pkey_free() is only to be called when there is nothing actively using
the key.  If you pkey_free() an in-use key, bad things happen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
