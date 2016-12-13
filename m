Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 524886B0069
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:27:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so347490136pgc.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:27:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p125si49253149pfp.119.2016.12.13.12.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:27:54 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
References: <20161213181511.GB2305@redhat.com>
 <1481653252.2473.51.camel@HansenPartnership.com>
 <20161213185545.GC2305@redhat.com>
 <1481659264.2473.59.camel@HansenPartnership.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4878d525-70cd-fa0e-b17f-4222c3166e74@intel.com>
Date: Tue, 13 Dec 2016 12:27:53 -0800
MIME-Version: 1.0
In-Reply-To: <1481659264.2473.59.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 12/13/2016 12:01 PM, James Bottomley wrote:
>> > Second aspect is that even if memory i am dealing with is un
>> > -addressable i still have struct page for it and i want to be able to 
>> > use regular page migration.
> Tmem keeps a struct page ... what's the problem with page migration?
> the fact that tmem locks the page when it's not addressable and you
> want to be able to migrate the page even when it's not addressable?

Hi James,

Why do you say that tmem keeps a 'struct page'?  For instance, its
->put_page operation _takes_ a 'struct page', but that's in the
delete_from_page_cache() path where the page's last reference has been
dropped and it is about to go away.  The role of 'struct page' here is
just to help create a key so that tmem can find the contents later
*without* the original 'struct page'.

Jerome's pages here are a new class of half-crippled 'struct page' which
support more VM features than ZONE_DEVICE pages, but not quite a full
feature set.  It supports (and needs to support) a heck of a lot more VM
features than memory in tmem would, though.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
