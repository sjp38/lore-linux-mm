Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7756B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 20:03:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q129-v6so3527713oic.9
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 17:03:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v128-v6sor18517807oib.252.2018.06.01.17.03.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 17:03:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180601170100.0a8e5567@thinkpad>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180518094616.GA25838@lst.de> <CAPcyv4iO1yss0sfBzHVDy3qja_wc+JT2Zi1zwtApDckTeuG2wQ@mail.gmail.com>
 <20180521090410.7ygosxzjfhceqrq4@quack2.suse.cz> <20180522062806.GD7816@lst.de>
 <20180523205017.0f2bc83e@thinkpad> <CAPcyv4gRvG=yT==SPgF940F7v9FqGqG-dQ8Vjcm0LPch86i1RA@mail.gmail.com>
 <20180601170100.0a8e5567@thinkpad>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 1 Jun 2018 17:03:55 -0700
Message-ID: <CAPcyv4is_iW6UjVrb4ZKJh=EuGjnCxm=O49kNAtOF5nrQG4+Ag@mail.gmail.com>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and CONFIG_DEV_PAGEMAP_OPS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Jun 1, 2018 at 8:01 AM, Gerald Schaefer
<gerald.schaefer@de.ibm.com> wrote:
> On Tue, 29 May 2018 13:26:33 -0700
> Dan Williams <dan.j.williams@intel.com> wrote:
>
>> On Wed, May 23, 2018 at 11:50 AM, Gerald Schaefer
>> <gerald.schaefer@de.ibm.com> wrote:
>> > On Tue, 22 May 2018 08:28:06 +0200
>> > Christoph Hellwig <hch@lst.de> wrote:
>> >
>> >> On Mon, May 21, 2018 at 11:04:10AM +0200, Jan Kara wrote:
>> >> > We definitely do have customers using "execute in place" on s390x from
>> >> > dcssblk. I've got about two bug reports for it when customers were updating
>> >> > from old kernels using original XIP to kernels using DAX. So we need to
>> >> > keep that working.
>> >>
>> >> That is all good an fine, but I think time has come where s390 needs
>> >> to migrate to provide the pmem API so that we can get rid of these
>> >> special cases.  Especially given that the old XIP/legacy DAX has all
>> >> kinds of known bugs at this point in time.
>> >
>> > I haven't yet looked at this patch series, but I can feel that this
>> > FS_DAX_LIMITED workaround is beginning to cause some headaches, apart
>> > from being quite ugly of course.
>> >
>> > Just to make sure I still understand the basic problem, which I thought
>> > was missing struct pages for the dcssblk memory, what exactly do you
>> > mean with "provide the pmem API", is there more to do?
>>
>> No, just 'struct page' is needed.
>>
>> What used to be the pmem API is now pushed down into to dax_operations
>> provided by the device driver. dcssblk is free to just redirect to the
>> generic implementations for copy_from_iter() and copy_to_iter(), and
>> be done. I.e. we've removed the "pmem API" requirement.
>>
>> > I do have a prototype patch lying around that adds struct pages, but
>> > didn't yet have time to fully test/complete it. Of course we initially
>> > introduced XIP as a mechanism to reduce memory consumption, and that
>> > is probably the use case for the remaining customer(s). Adding struct
>> > pages would somehow reduce that benefit, but as long as we can still
>> > "execute in place", I guess it will be OK.
>>
>> The pmem driver has the option to allocate the 'struct page' map out
>> of pmem directly. If the overhead of having the map in System RAM is
>> too high it could borrow the same approach, but that adds another
>> degree of configuration complexity freedom.
>>
>
> Thanks for clarifying, and mentioning the pmem altmap support, that
> looks interesting. I also noticed that I probably should enable
> CONFIG_ZONE_DEVICE for s390, and use devm_memremap_pages() to get
> the struct pages, rather than my homegrown solution so far. This will
> take some time however, so I hope you can live with the FS_DAX_LIMITED
> a little longer.
>

Yes, no urgent rush as far as I can see. Thanks Gerald.
