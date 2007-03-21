Message-ID: <4601598A.7060904@redhat.com>
Date: Wed, 21 Mar 2007 12:12:58 -0400
From: Chuck Ebbert <cebbert@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #3
References: <46005B4A.6050307@redhat.com>	<17920.61568.770999.626623@gargle.gargle.HOWL>	<460115D9.7030806@redhat.com> <17921.7074.900919.784218@gargle.gargle.HOWL> <46011E8F.2000109@redhat.com>
In-Reply-To: <46011E8F.2000109@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nikita Danilov <nikita@clusterfs.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nikita Danilov wrote:
> 
>> Probably I am missing something, but I don't see how that can help. For
>> example, suppose (for simplicity) that we have swappiness of 100%, and
>> that fraction of referenced anon pages gets slightly less than of file
>> pages. get_scan_ratio() increases anon_percent, and shrink_zone() starts
>> scanning anon queue more aggressively. As a result, pages spend less
>> time there, and have less chance of ever being accessed, reducing
>> fraction of referenced anon pages further, and triggering further
>> increase in the amount of scanning, etc. Doesn't this introduce positive
>> feed-back loop?
> 
> It's a possibility, but I don't think it will be much of an
> issue in practice.
> 
> If it is, we can always use refaults as a correcting
> mechanism - which would have the added benefit of being
> able to do streaming IO without putting any pressure on
> the active list, essentially clock-pro replacement with
> just some tweaks to shrink_list()...
> 

I think you're going to have to use refault rates. AIX 3.5 had
to add that. Something like:

if refault_rate(anonymous/mmap) > refault_rate(pagecache)
   drop a pagecache page
else
   drop either

You do have anonymous memory and mmapped executables in the same
queue, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
