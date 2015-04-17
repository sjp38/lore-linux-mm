Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 702176B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 13:38:22 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so157110445qkh.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 10:38:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jf5si12311809qcb.8.2015.04.17.10.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 10:38:20 -0700 (PDT)
Message-ID: <553144EB.9060701@redhat.com>
Date: Fri, 17 Apr 2015 18:37:47 +0100
From: John Spray <john.spray@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com> <55310957.3070101@gmail.com> <55311DE2.9000901@redhat.com> <20150417154351.GA26736@quack.suse.cz> <55312FEA.3030905@redhat.com> <20150417162247.GB27500@quack.suse.cz>
In-Reply-To: <20150417162247.GB27500@quack.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org



On 17/04/2015 17:22, Jan Kara wrote:
> On Fri 17-04-15 17:08:10, John Spray wrote:
>> On 17/04/2015 16:43, Jan Kara wrote:
>> In that case I'm confused -- why would ENOSPC be an appropriate use
>> of this interface if the mount being entirely blocked would be
>> inappropriate?  Isn't being unable to service any I/O a more
>> fundamental and severe thing than being up and healthy but full?
>>
>> Were you intending the interface to be exclusively for data
>> integrity issues like checksum failures, rather than more general
>> events about a mount that userspace would probably like to know
>> about?
>    Well, I'm not saying we cannot have those events for fs availability /
> inavailability. I'm just saying I'd like to see some use for that first.
> I don't want events to be added just because it's possible...
>
> For ENOSPC we have thin provisioned storage and the userspace deamon
> shuffling real storage underneath. So there I know the usecase.
>

Ah, OK.  So I can think of a couple of use cases:
  * a cluster scheduling service (think MPI jobs or docker containers) 
might check for events like this.  If it can see the cluster filesystem 
is unavailable, then it can avoid scheduling the job, so that the 
(multi-node) application does not get hung on one node with a bad 
mount.  If it sees a mount go bad (unavailable, or client evicted) 
partway through a job, then it can kill -9 the process that was relying 
on the bad mount, and go run it somewhere else.
  * Boring but practical case: a nagios health check for checking if 
mounts are OK.

We don't have to invent these event types now of course, but something 
to bear in mind.  Hopefully if/when any of the distributed filesystems 
(Lustre/Ceph/etc) choose to implement this, we can look at making the 
event types common at that time though.

BTW in any case an interface for filesystem events to userspace will be 
a useful addition, thank you!

Cheers,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
