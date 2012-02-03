Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7BCC06B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 02:09:18 -0500 (EST)
Received: by yenq11 with SMTP id q11so1894916yen.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 23:09:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F2B02BC.8010308@gmail.com>
References: <20120116163106.GC7180@jl-vm1.vm.bytemark.co.uk>
	<1326776095-2629-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<CAAHN_R2g9zaujw30+zLf91AGDHNqE6HDc8Z4yJbrzgJcJYFkXg@mail.gmail.com>
	<4F2B02BC.8010308@gmail.com>
Date: Fri, 3 Feb 2012 12:39:17 +0530
Message-ID: <CAAHN_R0O7a+RX7BDfas3+vC+mnQpp0h3y4bBa1u4T-Jt=S9J_w@mail.gmail.com>
Subject: Re: [RESEND][PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jamie Lokier <jamie@shareable.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

On Fri, Feb 3, 2012 at 3:10 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> =A0extern unsigned long move_page_tables(struct vm_area_struct *vma,
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 3f758c7..2f9f540 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -992,6 +992,9 @@ unsigned long do_mmap_pgoff(struct file *file,
>> unsigned long addr,
>> =A0 =A0 =A0 =A0vm_flags =3D calc_vm_prot_bits(prot) | calc_vm_flag_bits(=
flags) |
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm->def_flags | VM_MAYREA=
D | VM_MAYWRITE |
>> VM_MAYEXEC;
>>
>> + =A0 =A0 =A0 if (flags& =A0MAP_STACK)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vm_flags |=3D VM_STACK_FLAGS;
>
>
> ??
> MAP_STACK doesn't mean auto stack expansion. Why do you turn on
> VM_GROWSDOWN?
> Seems incorrect.
>

Right now MAP_STACK does not mean anything since it is ignored. The
intention of this behaviour change is to make MAP_STACK mean that the
map is going to be used as a stack and hence, set it up like a stack
ought to be. I could not really think of a valid case for fixed size
stacks; it looks like a limitation in the pthread implementation in
glibc rather than a feature. So this patch will actually result in
uniform behaviour across threads when it comes to stacks.

This does change vm accounting since thread stacks were earlier
accounted as anon memory.

--=20
Siddhesh Poyarekar
http://siddhesh.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
