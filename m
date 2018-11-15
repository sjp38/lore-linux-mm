Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F03366B028E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:20:52 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 80so44454082qkd.0
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:20:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b3si991255qkd.129.2018.11.15.03.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 03:20:52 -0800 (PST)
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
 <20181115111023.GC26448@zn.tnic>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4aa5d39d-a923-87de-d646-70b9cbfe62f0@redhat.com>
Date: Thu, 15 Nov 2018 12:20:40 +0100
MIME-Version: 1.0
In-Reply-To: <20181115111023.GC26448@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Dave Young <dyoung@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Lianbo Jiang <lijiang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 15.11.18 12:10, Borislav Petkov wrote:
> On Thu, Nov 15, 2018 at 02:19:23PM +0800, Dave Young wrote:
>> It would be good to copy some background info from cover letter to the
>> patch description so that we can get better understanding why this is
>> needed now.
>>
>> BTW, Lianbo is working on a documentation of the vmcoreinfo exported
>> fields. Ccing him so that he is aware of this.
>>
>> Also cc Boris,  although I do not want the doc changes blocks this
>> he might have different opinion :)
> 
> Yeah, my initial reaction is that exporting an mm-internal flag to
> userspace is a no-no.

Sorry to say, but that is the current practice without which
makedumpfile would not be able to work at all. (exclude user pages,
exclude page cache, exclude buddy pages). Let's not reinvent the wheel
here. This is how dumping works forever.

Also see how hwpoisoned pages are handled.

(please note that most distributions only support dumping via
makedumpfile, for said reasons)

> 
> What would be better, IMHO, is having a general method of telling the
> kdump kernel - maybe ranges of physical addresses - which to skip.

And that has to be updated whenever we change a page flag. But then the
dump kernel would have to be aware about "struct page" location and
format of some old kernel to be dump. Let's just not even discuss going
down that path.

> 
> Because the moment there's a set of pages which do not have PG_offline
> set but kdump would still like to skip, this breaks.

I don't understand your concern. PG_offline is only an optimization for
sections that are online. Offline sections can already be completely
ignored when dumping.

I don't see how there should be "set of pages which do not have
PG_offline". I mean if they don't have PG_offline they will simply be
dumped like before. Which worked forever. Sorry, I don't get your point.

-- 

Thanks,

David / dhildenb
