Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10A546B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 09:36:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id os4so11961641pac.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 06:36:08 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id e67si40623983pfg.132.2016.10.19.06.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 06:36:07 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CAOQ4uxjyZF346vq-Oi=HwB=jj6ePycHBnEfvVPet9KqPxL9mgg@mail.gmail.com>
Date: Wed, 19 Oct 2016 08:33:58 -0500
In-Reply-To: <CAOQ4uxjyZF346vq-Oi=HwB=jj6ePycHBnEfvVPet9KqPxL9mgg@mail.gmail.com>
	(Amir Goldstein's message of "Wed, 19 Oct 2016 09:13:01 +0300")
Message-ID: <87mvi0mpix.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>

Amir Goldstein <amir73il@gmail.com> writes:

>> diff --git a/fs/exec.c b/fs/exec.c
>> index 6fcfb3f7b137..f724ed94ba7a 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1270,12 +1270,21 @@ EXPORT_SYMBOL(flush_old_exec);
>>
>>  void would_dump(struct linux_binprm *bprm, struct file *file)
>>  {
>> -       if (inode_permission(file_inode(file), MAY_READ) < 0)
>> +       struct inode *inode = file_inode(file);
>> +       if (inode_permission(inode, MAY_READ) < 0) {
>> +               struct user_namespace *user_ns = current->mm->user_ns;
>>                 bprm->interp_flags |= BINPRM_FLAGS_ENFORCE_NONDUMP;
>> +
>> +               /* May the user_ns root read the executable? */
>> +               if (!kuid_has_mapping(user_ns, inode->i_uid) ||
>> +                   !kgid_has_mapping(user_ns, inode->i_gid)) {
>> +                       bprm->interp_flags |= BINPRM_FLAGS_EXEC_INACCESSIBLE;
>> +               }
>
> This feels like it should belong inside
> inode_permission(file_inode(file), MAY_EXEC)
> which hopefully should be checked long before getting here??

It is the active ingredient in capable_wrt_inode_uidgid and is indeed
inside of inode_permission.

What I am testing for here is if I have a process with a full
set of capabilities in current->mm->user_ns will the inode be readable.

I can see an argument for calling prepare_creds stuffing the new cred
full of capabilities.  Calling override_cred.  Calling inode_permission,
restoring the credentials.  But it seems very much like overkill and
more error prone because of the more code involved.

So I have done the simple thing that doesn't hide what is really going on.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
