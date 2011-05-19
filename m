Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 69C446B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:37:53 -0400 (EDT)
Received: by qyk30 with SMTP id 30so1582507qyk.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 17:37:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105181709540.1282@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
	<BANLkTi=4YY6aJk+ZLiiF7UX73LZD=7+W2Q@mail.gmail.com>
	<alpine.LSU.2.00.1105181709540.1282@sister.anvils>
Date: Thu, 19 May 2011 09:37:51 +0900
Message-ID: <BANLkTi=bLOzrEPVx8ossZtaxe3OmH9ZXNw@mail.gmail.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Thu, May 19, 2011 at 9:28 AM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 19 May 2011, Minchan Kim wrote:
>> On Wed, May 18, 2011 at 3:24 AM, Hugh Dickins <hughd@google.com> wrote:
>> > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
>> > target mm, not for current mm (but of course they're usually the same)=
.
>> >
>> > We don't know the target mm in shmem_getpage(), so do it at the outer
>> > level in shmem_fault(); and it's easier to follow if we move the
>> > count_vm_event(PGMAJFAULT) there too.
>> >
>> > Hah, it was using __count_vm_event() before, sneaking that update into
>> > the unpreemptible section under info->lock: well, it comes to the same
>> > on x86 at least, and I still think it's best to keep these together.
>> >
>> > Signed-off-by: Hugh Dickins <hughd@google.com>
>>
>> It's good to me but I have a nitpick.
>>
>> You are changing behavior a bit.
>> Old behavior is to account FAULT although the operation got failed.
>> But new one is to not account it.
>> I think we have to account it regardless of whether it is successful or =
not.
>> That's because it is fact fault happens.
>
> That's a good catch: something I didn't think of at all.
>
> However, it looks as if the patch remains correct, and is fixing
> a bug (or inconsistency) that we hadn't noticed before.
>
> If you look through filemap_fault() or do_swap_page() (or even
> ncp_file_mmap_fault(), though I don't take that one as canonical!),
> they clearly do not count the major fault on error (except in the
> case where VM_FAULT_MAJOR needs VM_FAULT_RETRY, then gets
> VM_FAULT_ERROR on the retry).
>
> So, shmem.c was the odd one out before. =C2=A0If you feel very strongly
> about it ("it is fact fault happens") you could submit a patch to
> change them all - but I think just leave them as is.

Okay. I don't feel it strongly now.
Then, could you repost your patch with corrected description about
this behavior change which is a bug or inconsistency whatever. :)


>
> Hugh
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
