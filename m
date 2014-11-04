Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B06306B0075
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 10:57:38 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so14673699pab.4
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 07:57:38 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id qe5si703727pdb.2.2014.11.04.07.57.36
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 07:57:37 -0800 (PST)
Message-ID: <5458F6E2.9020305@fb.com>
Date: Tue, 4 Nov 2014 10:55:14 -0500
From: Josef Bacik <jbacik@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tmpfs: truncate prealloc blocks past i_size
References: <1414602608-1416-1-git-send-email-jbacik@fb.com> <alpine.LSU.2.11.1411031710500.13943@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1411031710500.13943@eggly.anvils>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, dave Chinner <david@fromorbit.com>

On 11/03/2014 08:30 PM, Hugh Dickins wrote:
> On Wed, 29 Oct 2014, Josef Bacik wrote:
>
>> One of the rocksdb people noticed that when you do something like this
>>
>> fallocate(fd, FALLOC_FL_KEEP_SIZE, 0, 10M)
>> pwrite(fd, buf, 5M, 0)
>> ftruncate(5M)
>>
>> on tmpfs the file would still take up 10M, which lead to super fun issues
>> because we were getting ENOSPC before we thought we should be getting ENOSPC.
>> This patch fixes the problem, and mirrors what all the other fs'es do.  I tested
>> it locally to make sure it worked properly with the following
>>
>> xfs_io -f -c "falloc -k 0 10M" -c "pwrite 0 5M" -c "truncate 5M" file
>>
>> Without the patch we have "Blocks: 20480", with the patch we have the correct
>> value of "Blocks: 10240".  Thanks,
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>
> That is a very good catch, and thank you for the patch.  But I am not
> convinced that the patch is correct - even if it does happen to end
> up doing what other filesystems do here (I haven't checked).
>
> Your patch makes it look like a fix to an off-by-one, but that is
> not really the case.  What if you change your final ftruncate(5M)
> to ftruncate(6M): what should happen then?
>
> My intuition says that what should happen is that i_size is set to 6M,
> and the fallocated excess blocks beyond 6M be trimmed off: so that
> it's both an extending and a shrinking truncate at the same time.
> And I think that behavior would be served by removing the
> "if (newsize < oldsize)" condition completely.
>
> But perhaps I'm wrong: can you or anyone shed more light on this,
> or point to documentation of what should happen in these cases?
>

Yup there's a section in the ftruncate manpage that specifically says 
"expanding truncate is for losers."

Dave you want to weigh in here?  Looking at both btrfs and xfs we only 
do the trimming if newsize <= oldsize.  So if you falloc up to 10M, 
write 5M, and truncate up to 6M there is no trimming.  I'd say this is 
ok since it's an expanding truncate, people doing this are probably 
going to want to keep the extra space, as opposed to those who falloc a 
chunk and then truncate down to the amount they actually wrote.  Thoughts?

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
