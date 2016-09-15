Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9CF6B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 19:19:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 184so15187680ity.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 16:19:23 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id r65si183672oia.210.2016.09.15.16.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 16:19:22 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id m11so91697536oif.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 16:19:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160915230748.GS30497@dastard>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160915082615.GA9772@lst.de> <CAPcyv4jTw3cXpmmJRh7t16Xy2uYofDe+fJ+X_jnz+Q=o0uGneg@mail.gmail.com>
 <20160915230748.GS30497@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 15 Sep 2016 16:19:21 -0700
Message-ID: <CAPcyv4hm4MBDQNJvOgqeG2OaA14WJ8kN5rSndusbhG3K=LP2JQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm, dax: add VM_DAX flag for DAX VMAs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, XFS Developers <xfs@oss.sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 15, 2016 at 4:07 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Thu, Sep 15, 2016 at 10:01:03AM -0700, Dan Williams wrote:
>> On Thu, Sep 15, 2016 at 1:26 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > On Wed, Sep 14, 2016 at 11:54:38PM -0700, Dan Williams wrote:
>> >> The DAX property, page cache bypass, of a VMA is only detectable via the
>> >> vma_is_dax() helper to check the S_DAX inode flag.  However, this is
>> >> only available internal to the kernel and is a property that userspace
>> >> applications would like to interrogate.
>> >
>> > They have absolutely no business knowing such an implementation detail.
>>
>> Hasn't that train already left the station with FS_XFLAG_DAX?
>
> No, that's an admin flag, not a runtime hint for applications. Just
> because that flag is set on an inode, it does not mean that DAX is
> actually in use - it will be ignored if the backing dev is not dax
> capable.

Ok, but then VM_DAX does not suffer from that problem.  I'm trying to
understand why VM_DAX has no business being in the smaps "VmFlags"
line, but something ambiguous to userspace like VM_MIXEDMAP does?

>
>> The other problem with hiding the DAX property is that it turns out to
>> not be a transparent acceleration feature.  See xfs/086 xfs/088
>> xfs/089 xfs/091 which fail with DAX and, as far as I understand, it is
>> due to the fact that DAX disallows delayed allocation behavior.
>
> Which is not a bug, nor is it something that app developers should
> be surprised by.
>
> i.e. Subtle differences in error reporting behaviour occur in
> filesystems /all the time/. Run the test on a non-dax filesystem
> with an extent size hint. It fails /exactly the same way as DAX/.
> Run it with direct IO - fails the same way as DAX. Run it
> with synchronous writes - it fails the same way as DAX.
>
> IOWs, if an app can't handle the way DAX reports errors, then they
> are /broken/. Delayed allocation requires checking the return value
> of fsync() or close() to capture the allocation error - many more
> apps get that wrong than the ones that expect the immediate errors
> from write()...
>
> Anyway: to domeonstrate that the nothign is actually broken, and
> you might sometimes need to fix tests and send patches to
> fstests@vger.kernel.org, this makes xfs/086 pass for me on DAX:
>
> --- a/tests/xfs/086
> +++ b/tests/xfs/086
> @@ -96,7 +96,8 @@ _scratch_mount
>
>  echo "+ modify files"
>  for x in `seq 1 64`; do
> -       $XFS_IO_PROG -f -c "pwrite -S 0x62 0 ${blksz}" "${TESTFILE}.${x}" >> $seqres.full
> +       $XFS_IO_PROG -f -c "pwrite -S 0x62 0 ${blksz}" "${TESTFILE}.${x}" \
> +               >> $seqres.full 2>&1
>  done
>  umount "${SCRATCH_MNT}"

Thanks for that!  Wasn't immediately obvious to me, and didn't get
that response when I asked on the list a while back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
