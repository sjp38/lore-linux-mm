Message-ID: <47872CA7.40802@de.ibm.com>
Date: Fri, 11 Jan 2008 09:45:27 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting
 for VM_MIXEDMAP pages
References: <20071214133817.GB28555@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com>
In-Reply-To: <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
>> I think you're looking for
>> pfn_has_struct_page_entry_for_it(), and that's different from the
>> original meaning described above.
> 
> Yes.  That's what I'm looking for.
> 
> Carsten,
> 
> I think I get the problem now.  You've been saying over and over, I
> just didn't hear it.  We are not using the same assumptions for what
> VM_MIXEDMAP means.
> 
> Look's like today most architectures just use pfn_valid() to see if a
> pfn is in a valid RAM segment.  The assumption used in
> vm_normal_page() is that valid_RAM == has_page_struct.  That's fine by
> me for VM_MIXEDMAP because I'm only assuming 2 states a page can be
> in: (1) page struct RAM (2) pfn only Flash memory ioremap()'ed in.
> You are wanting to add a third: (3) valid RAM, pfn only mapping with
> the ability to add a page struct when needed.
> 
> Is this right?
About right. There are a few differences between "valid ram" and our 
DCSS segments, but yes. Our segments are not present at system 
startup, and can be "loaded" afterwards by hypercall. Thus, they're 
not detected and initialized as regular memory.
We have the option to add struct page entries for them. In case of 
using the segment for xip, we don't want struct page entries and 
rather prefer VM_MIXEDMAP, but with regular memory (with struct page) 
being used after cow.
The segments can either be exclusive for one Linux image, or shared 
between multiple. And they can be read-only or read+write. A memory 
store to a read-only segment would fail. For xip, we either use 
"shared, read-only" or "exclusive, read+write".  I think in your 
categories we're like
(3) valid RAM that may be read-only, pfn only mapping, no struct page

>> Jared, did you try this on arm?
> 
> No.  I'm not sure where we stand.  Shall I bother or do I wait for the
> next patch?
I guess we should wait for Nick's patch. He has already decided not to 
go down this path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
