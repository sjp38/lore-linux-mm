Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B49426B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 13:54:35 -0400 (EDT)
Message-ID: <4C1A6179.5000807@vlnb.net>
Date: Thu, 17 Jun 2010 21:55:05 +0400
From: Vladislav Bolkhovitin <vst@vlnb.net>
MIME-Version: 1.0
Subject: Re: Current topics for LSF10/MM Summit 8-9 August in Boston
References: <1276721459.2847.399.camel@mulgrave.site>	 <20100617160048.GA11689@schmichrtp.mainz.de.ibm.com>	 <1276790850.7398.8.camel@mulgrave.site>  <4C1A4EA9.40504@vlnb.net>	 <1276792935.7398.19.camel@mulgrave.site>  <4C1A5751.7030704@vlnb.net> <1276796269.7398.86.camel@mulgrave.site>
In-Reply-To: <1276796269.7398.86.camel@mulgrave.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>, Gennadiy Nerubayev <parakie@gmail.com>
Cc: Christof Schmitt <christof.schmitt@de.ibm.com>, linux-scsi@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf10-pc@lists.linuxfoundation.org, Boaz Harrosh <bharrosh@panasas.com>
List-ID: <linux-mm.kvack.org>

James Bottomley, on 06/17/2010 09:37 PM wrote:
> On Thu, 2010-06-17 at 21:11 +0400, Vladislav Bolkhovitin wrote:
>> James Bottomley, on 06/17/2010 08:42 PM wrote:
>>> On Thu, 2010-06-17 at 20:34 +0400, Vladislav Bolkhovitin wrote:
>>>> James Bottomley, on 06/17/2010 08:07 PM wrote:
>>>>> On Thu, 2010-06-17 at 18:00 +0200, Christof Schmitt wrote:
>>>>>> On Wed, Jun 16, 2010 at 03:50:59PM -0500, James Bottomley wrote:
>>>>>>> Given that we're under two months out, I thought it would be time to
>>>>>>> post a summary of the topics we've collected so far (Nick will post the
>>>>>>> MM summit ones later).  Look this over, and if there's anything missing,
>>>>>>> propose it ... or if you have cross Storage/FS/MM topics, post them too.
>>>>>>>
>>>>>>> Oh, and since we're not the most organised bunch, if you posted a topic
>>>>>>> and don't see it in the list, please resend ... we probably lost it in
>>>>>>> an email shuffle.
>>>>>>>
>>>>>>> Current Filesystem Topics:
>>>>>>>
>>>>>>> Alex Elder	Upstream maintainer for XFS, general discussion on FS/IO
>>>>>>> Aneesh Kumar	Rich-acl patches which work better with NFSv4 acl and CIFS acl
>>>>>>> Anshul Madan	reflink for NFS
>>>>>>> Chuck Lever	NFS/IPV6 and NFS O_DIRECT, Wu's read-ahead work, vitro perf tools
>>>>>>> Eric Sandeen	Advances in testing, TRIM/DISCARD/Alignment, writeback sanity
>>>>>>> James Lentini	reflink for NFS
>>>>>>> Jan Kara	Discuss/drive sanity review of writeback and general ext*/jbd 
>>>>>>> Michael Rubin	Writeback scaling
>>>>>>> Sage Weil	Statlite, generic interface for describing file striping for distributed FS, VFS scalability
>>>>>>> Al Viro	Sorting out d_revalidate and other dcache issues
>>>>>>> Coly Li		directory/large file scalability
>>>>>>> Sorin Faibish	Cache writeback discussion
>>>>>>>
>>>>>>> Current Storage Topics:
>>>>>>>
>>>>>>> Eric Seppanen	Next generation SSDs, performance implications on Linux I/O
>>>>>>> Boaz Harrosh	PNFS performance considerations, bio_list based/async raidN for generic use; stable pages for I/O
>>>>>>> FUJITA Tomonori	SCSI target mode, iSCSI, block layer SG (bsg), sg, IOMMU, DMA issues
>>>>>>> Hannes Reinecke	libfc/multipath/error handing
>>>>>>> James Smart	FCOE proposal for rework of the FC sysfs tree, work with Hannes on other transport/SCSI subsystem topics
>>>>>>> Jeff Moyer	IO scheduler
>>>>>>> Joel Becker	SAN management plugin
>>>>>>> Martin Petersen	Updates on DIF/DIX, TRIM/DISCARD/UNMAP, generic support for WRITE_SAME
>>>>>>>
>>>>>>> Plus some MM summit ones which Nick will summarise.
>>>>>> [...]
>>>>>>
>>>>>> What about the topic "Stable pages while IO"?
>>>>>> http://www.spinics.net/lists/linux-scsi/msg44074.html
>>>>>>
>>>>>> Was it lost during the e-mail shuffle or will it be part of the MM topics?
>>>>> It's actually listed under 'dma issues' ... but there's really been no
>>>>> satisfactory resolution or discussion of how one might be achieved.
>>>>> Most filesystems rely on modifications to in-flight pages for efficiency
>>>>> and copying every fs I/O page would be horrendous both for performance
>>>>> and memory consumption.  Nor has there really been an indication that
>>>>> it's a serious issue.  The two sufferers are DIF and iSCSI checksum.
>>>> You forgot the third: advanced storage, including MPIO clusters, where 
>>>> retry of the write of the modified in-flight pages while the original 
>>>> write for them not yet completed might cause out of the expected order 
>>>> execution of the writes and data corruption (old data written instead of 
>>>> new).
>>> I don't think that's a problem. Multiple commands in flight to the same
>>> I/O region can get reordered because we only use simple tagging
>>> regardless of advanced or otherwise storage. The VM seems to wait for
>>> one write to complete before starting another because of the way the
>>> flush threads work.
>> I hope so, but: (1) we can see such writes (see 
>> http://lists.linbit.com/pipermail/drbd-user/2009-April/011891.html, for 
>> instance)
> 
> So the email says blockio mode ... which I take it isn't through the
> pagecache cleaning?  All bets are off if the user initiates the
> writeback ... and certainly you can get two blocks in flight for the
> same destination using DIRECT IO ... but that's up to the applications
> to fix ... we don't guarantee ordering in that case.

That's blockio on the target. The target stack just passed down to its 
backstorage incoming from the initiator SCSI commands as a block 
requests in 1:1 mapping. But the SCSI commands were sent by the 
initiator. So, the concurrent writes came from the initiator.

Gennadiy,

Which application did you use on the initiator to generate load when you 
had the concurrent writes?

Vlad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
