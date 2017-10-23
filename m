Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5456B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:20:48 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e68so17868246oih.21
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:20:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w126sor2323739oie.96.2017.10.23.04.20.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 04:20:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171023124427.10d15ee3@mschwideX1>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020075735.GA14378@lst.de> <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
 <20171020162933.GA26320@lst.de> <20171023071835.67ee5210@mschwideX1>
 <CAPcyv4hqiV6oHMgFik3MBTw5SJ6hcq4RzngPn2Xtp9kAv1E+Ow@mail.gmail.com> <20171023124427.10d15ee3@mschwideX1>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 23 Oct 2017 04:20:46 -0700
Message-ID: <CAPcyv4jTO7peOJ1zUocZiuqejoZmhtUYZbYcM==U+R-frB+sgA@mail.gmail.com>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Mon, Oct 23, 2017 at 3:44 AM, Martin Schwidefsky
<schwidefsky@de.ibm.com> wrote:
> On Mon, 23 Oct 2017 01:55:20 -0700
> Dan Williams <dan.j.williams@intel.com> wrote:
>
>> On Sun, Oct 22, 2017 at 10:18 PM, Martin Schwidefsky
>> <schwidefsky@de.ibm.com> wrote:
>> > On Fri, 20 Oct 2017 18:29:33 +0200
>> > Christoph Hellwig <hch@lst.de> wrote:
>> >
>> >> On Fri, Oct 20, 2017 at 08:23:02AM -0700, Dan Williams wrote:
>> >> > Yes, however it seems these drivers / platforms have been living wi=
th
>> >> > the lack of struct page for a long time. So they either don't use D=
AX,
>> >> > or they have a constrained use case that never triggers
>> >> > get_user_pages(). If it is the latter then they could introduce a n=
ew
>> >> > configuration option that bypasses the pfn_t_devmap() check in
>> >> > bdev_dax_supported() and fix up the get_user_pages() paths to fail.
>> >> > So, I'd like to understand how these drivers have been using DAX
>> >> > support without struct page to see if we need a workaround or we ca=
n
>> >> > go ahead delete this support. If the usage is limited to
>> >> > execute-in-place perhaps we can do a constrained ->direct_access() =
for
>> >> > just that case.
>> >>
>> >> For axonram I doubt anyone is using it any more - it was a very for
>> >> the IBM Cell blades, which were produce=D1=95 in a rather limited num=
ber.
>> >> And Cell basically seems to be dead as far as I can tell.
>> >>
>> >> For S/390 Martin might be able to help out what the status of xpram
>> >> in general and DAX support in particular is.
>> >
>> > The goes back to the time where DAX was called XIP. The initial design
>> > point has been *not* to have struct pages for a large read-only memory
>> > area. There is a block device driver for z/VM that maps a DCSS segment
>> > somewhere in memore (no struct page!) with e.g. the complete /usr
>> > filesystem. The xpram driver is a different beast and has nothing to
>> > do with XIP/DAX.
>> >
>> > Now, if any there are very few users of the dcssblk driver out there.
>> > The idea to save a few megabyte for /usr never really took of.
>> >
>> > We have to look at our get_user_pages() implementation to see how hard
>> > it would be to make it fail if the target address is for an area witho=
ut
>> > struct pages.
>>
>> For read-only memory I think we can enable a subset of DAX, and
>> explicitly turn off the paths that require get_user_pages(). However,
>> I wonder if anyone has tested DAX with dcssblk because fork() requires
>> get_user_pages()?
>
> I did not test it recently, someone else might have. Gerald?
>
> Looking at the code I see this in the s390 version of gup_pte_range:
>
>         mask =3D (write ? _PAGE_PROTECT : 0) | _PAGE_INVALID | _PAGE_SPEC=
IAL;
>         ...
>                 if ((pte_val(pte) & mask) !=3D 0)
>                         return 0;
>         ...
>
> The XIP code used the pte_mkspecial mechanics to make it work. As far as
> I can see the pfn_t_devmap returns true for the DAX mappins, yes?

Yes, but that's only for get_user_pages_fast() support.

> Then I would say that dcssblk and DAX currently do not work together.

I think at a minimum we need a new pfn_t flag for the 'special' bit to
at least indicate that DAX mappings of dcssblk and axonram do not
support normal get_user_pages(). Then I don't need to explicitly
disable DAX in the !pfn_t_devmap() case. I think I also want to split
the "pfn_to_virt()" and the "sector to pfn" operations into distinct
dax_operations rather than doing both in one ->direct_access(). This
supports storing pfns in the fs/dax radix rather than sectors.

In other words, the pfn_t_devmap() requirement was only about making
get_user_pages() safely fail, and pte_special() fills that
requirement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
