Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 55E356B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:33:05 -0500 (EST)
Message-ID: <50B6830A.20308@oracle.com>
Date: Wed, 28 Nov 2012 15:32:58 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: Re: O_DIRECT on tmpfs (again)
References: <x49ip8rf2yw.fsf@segfault.boston.devel.redhat.com> <alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1211281248270.14968@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 11/28/2012 03:17 PM, Hugh Dickins wrote:
> On Tue, 27 Nov 2012, Jeff Moyer wrote:
> 
>> Hi Hugh and others,
>>
>> In 2007, there were some discussions on whether to allow opens to
>> specify O_DIRECT for files backed by tmpfs.[1][2] On the surface, it
>> sounds like a completely crazy thing to do.  However, distributions like
>> Fedora are now defaulting to using a tmpfs /tmp.  I'm not aware of any
>> applications that open temp files using O_DIRECT, but I wanted to get
>> some new discussion going on whether this is a reasonable thing to
>> expect to work.
>>
>> Thoughts?
>>
>> Cheers,
>> Jeff
>>
>> [1] https://lkml.org/lkml/2007/1/4/55
>> [2] http://thread.gmane.org/gmane.linux.kernel/482031
> 
> Thanks a lot for refreshing my memory with those links.
> 
> Whilst I agree with every contradictory word I said back then ;)
> my current position is to wait to see what happens with Shaggy's "loop:
> Issue O_DIRECT aio using bio_vec" https://lkml.org/lkml/2012/11/22/847

As the patches exist today, the loop driver will only make the aio calls
if the underlying file defines a direct_IO address op since
generic_file_read/write_iter() will call a_ops->direct_IO() when
O_DIRECT is set. For tmpfs or any other filesystem that doesn't support
O_DIRECT, the loop driver will continue to call the read() or write()
method.

> 
> I've been using loop on tmpfs-file in testing for years, and will not
> allow that to go away.  I've not yet tried applying the patches and
> fixing up mm/shmem.c to suit, but will make sure that it's working
> before a release emerges with those changes in.
> 
> It would be possible to add nominal O_DIRECT support to tmpfs without
> that, and perhaps it would be possible to add that loop support without
> enabling O_DIRECT from userspace; but my inclination is to make those
> changes together.
> 
> (I'm not thinking of doing ramfs and hugetlbfs too.)
> 
> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
