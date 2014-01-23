Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id AF9B86B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:46:29 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so510129yha.40
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 18:46:29 -0800 (PST)
Received: from bifrost.lang.hm (mail.lang.hm. [64.81.33.126])
        by mx.google.com with ESMTPS id g10si1770093yhn.159.2014.01.22.18.46.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 18:46:27 -0800 (PST)
Date: Wed, 22 Jan 2014 18:46:11 -0800 (PST)
From: David Lang <david@lang.hm>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
In-Reply-To: <1390421691.1198.43.camel@ret.masoncoding.com>
Message-ID: <alpine.DEB.2.02.1401221836330.13577@nftneq.ynat.uz>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>  <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>  <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>  <20140122151913.GY4963@suse.de>
 <1390410233.1198.7.camel@ret.masoncoding.com>  <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>  <1390413819.1198.20.camel@ret.masoncoding.com>  <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>  <52E00B28.3060609@redhat.com>
 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>  <52E0106B.5010604@redhat.com>  <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>  <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
 <1390421691.1198.43.camel@ret.masoncoding.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "James.Bottomley@hansenpartnership.com" <James.Bottomley@hansenpartnership.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 22 Jan 2014, Chris Mason wrote:

> On Wed, 2014-01-22 at 11:50 -0800, Andrew Morton wrote:
>> On Wed, 22 Jan 2014 11:30:19 -0800 James Bottomley <James.Bottomley@hansenpartnership.com> wrote:
>>
>>> But this, I think, is the fundamental point for debate.  If we can pull
>>> alignment and other tricks to solve 99% of the problem is there a need
>>> for radical VM surgery?  Is there anything coming down the pipe in the
>>> future that may move the devices ahead of the tricks?
>>
>> I expect it would be relatively simple to get large blocksizes working
>> on powerpc with 64k PAGE_SIZE.  So before diving in and doing huge
>> amounts of work, perhaps someone can do a proof-of-concept on powerpc
>> (or ia64) with 64k blocksize.
>
>
> Maybe 5 drives in raid5 on MD, with 4K coming from each drive.  Well
> aligned 16K IO will work, everything else will about the same as a rmw
> from a single drive.

I think this is the key point to think about here. How will these new hard drive 
large block sizes differ from RAID stripes and SSD eraseblocks?

In all of these cases there are very clear advantages to doing the writes in 
properly sized and aligned chunks that correspond with the underlying structure 
to avoid the RMW overhead.

It's extremely unlikely that drive manufacturers will produce drives that won't 
work with any existing OS, so they are going to support smaller writes in 
firmware. If they don't, they won't be able to sell their drives to anyone 
running existing software. Given the Enterprise software upgrade cycle compared 
to the expanding storage needs, whatever they ship will have to work on OS and 
firmware releases that happened several years ago.

I think what is needed is some way to be able to get a report on how man RMW 
cycles have to happen. Then people can work on ways to reduce this number and 
measure the results.

I don't know if md and dm are currently smart enough to realize that the entire 
stripe is being overwritten and avoid the RMW cycle. If they can't, I would 
expect that once we start measuring it, they will gain such support.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
