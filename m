Message-ID: <45DE034D.7080000@redhat.com>
Date: Thu, 22 Feb 2007 15:55:41 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <20070221202615.a0a167f4.akpm@linux-foundation.org> <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu> <45DDD55F.4060106@redhat.com> <E1HKIN1-0006RX-00@dorka.pomaz.szeredi.hu> <45DDF9C1.4090003@redhat.com> <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu>
In-Reply-To: <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:
>>> __fput() will be called when there are no more references to 'file',
>>> then it will update the time if the flag is set.  This applies to
>>> regular files as well as devices.
>>>
>>>   
>>>       
>> I suspect that you will find that, for a block device, the wrong inode
>> gets updated.  That's where the bd_inode_update_time() portion of my
>> proposed patch came from.
>>     
>
> How horrible :( I haven't noticed that part of the patch.  But I don't
> think that's needed.  Updating the times through the file pointer
> should be OK.  You have this problem because you use the inode which
> comes from the blockdev pseudo-filesystem.
>
>   

It was nasty, I certainly agree.  :-)

>>> But I've moved the check from __fput to remove_vma() in the next
>>> revision of the patch, which would give slightly nicer semantics, and
>>> be equally conforming.
>>>       
>> This still does not address the situation where a file is 'permanently'
>> mmap'd, does it?
>>     
>
> So?  If application doesn't do msync, then the file times won't be
> updated.  That's allowed by the standard, and so portable applications
> will have to call msync.

Well, there allowable by the specification, and then there is expected and
reasonable.  It seems reasonable to me that the file times should be
updated _sometime_, even if the application does not take proactive action
to cause them to be updated.  Otherwise, it would be easy to end up with a
file, whose contents are updated and reside on stable storage, but whose
mtime never changes.  Part of the motivation behind starting this work was
to address the situation where an application modifies files using mmap
but then backup software would never see the need to backup those files.

It seems to me that if something like sync() causes the file contents to
be written to stable storage, then the file metadata should follow in a
not too distant fashion.

    Thanx...

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
