Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F29D6B0023
	for <linux-mm@kvack.org>; Fri,  6 May 2011 02:01:39 -0400 (EDT)
Received: by bwz17 with SMTP id 17so3744847bwz.14
        for <linux-mm@kvack.org>; Thu, 05 May 2011 23:01:36 -0700 (PDT)
Message-ID: <4DC38EBD.5060300@suse.cz>
Date: Fri, 06 May 2011 08:01:33 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] coredump: use task comm instead of (unknown)
References: <4DC0FFAB.1000805@gmail.com>	<1304494354-21487-1-git-send-email-jslaby@suse.cz> <20110505150601.a4457970.akpm@linux-foundation.org>
In-Reply-To: <20110505150601.a4457970.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>, John Stultz <john.stultz@linaro.org>, Oleg Nesterov <oleg@redhat.com>Jiri Slaby <jirislaby@gmail.com>

Ccing Oleg.

On 05/06/2011 12:06 AM, Andrew Morton wrote:
> On Wed,  4 May 2011 09:32:34 +0200
> Jiri Slaby <jslaby@suse.cz> wrote:
> 
>> If we don't know the file corresponding to the binary (i.e. exe_file
>> is unknown), use "task->comm (path unknown)" instead of simple
>> "(unknown)" as suggested by ak.
>>
>> The fallback is the same as %e except it will append "(path unknown)".
>>
>> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
>> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
>> Cc: Al Viro <viro@zeniv.linux.org.uk>
>> Cc: Andi Kleen <andi@firstfloor.org>
>> ---
>>  fs/exec.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/exec.c b/fs/exec.c
>> index 5ee7562..0a4d281 100644
>> --- a/fs/exec.c
>> +++ b/fs/exec.c
>> @@ -1555,7 +1555,7 @@ static int cn_print_exe_file(struct core_name *cn)
>>  
>>  	exe_file = get_mm_exe_file(current->mm);
>>  	if (!exe_file)
>> -		return cn_printf(cn, "(unknown)");
>> +		return cn_printf(cn, "%s (path unknown)", current->comm);
>>  
>>  	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
>>  	if (!pathbuf) {
> 
> Direct access to current->comm is racy since we added
> prctl(PR_SET_NAME).
> 
> Hopefully John Stultz will soon be presenting us with a %p modifier for
> displaying task_struct.comm.

Then just make sure, you won't nest alloc_lock (task_lock) into siglock.

> But we should get this settled pretty promptly as this is a form of
> userspace-visible API.  Use get_task_comm() for now.

I thought about using get_task_comm, but was not sure, if it is safe to
task_lock() at that place. Note that this is copied from %e.

> Also, there's nothing which prevents userspace from rewriting
> task->comm to something which contains slashes (this seems bad).  If
> that is done, your patch will do Bad Things - it should be modified to
> use cn_print_exe_file()'s slash-overwriting codepath.

%E (cn_print_exe_file) does exactly what %e (format_corename) does. So
if this is really broken in the two ways, we should fix both the old %e
and the new %E.

I'm not sure whether at this point when the task is being killed and
dumped, it can still change comm?

For the slashes, I agree. That should be fixed in both cases.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
