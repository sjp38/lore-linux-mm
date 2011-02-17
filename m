Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 671E78D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:35:58 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p1HNZqqH023364
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:35:54 -0800
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz13.hot.corp.google.com with ESMTP id p1HNZofI011885
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:35:51 -0800
Received: by pwj3 with SMTP id 3so649354pwj.5
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:35:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D5C7EA7.1030409@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com>
From: Paul Menage <menage@google.com>
Date: Thu, 17 Feb 2011 15:35:30 -0800
Message-ID: <AANLkTinsj4OagOQhaPL=6-3awQo9ssh06NgwTg1kOsYh@mail.gmail.com>
Subject: Re: [PATCH 1/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_sprintf_memlist()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Wed, Feb 16, 2011 at 5:49 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> It's not necessary to copy cpuset->mems_allowed to a buffer
> allocated by NODEMASK_ALLOC(). Just pass it to nodelist_scnprintf().
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

The only downside is that we're now doing more work (and more complex
work) inside callback_mutex, but I guess that's OK compared to having
to do a memory allocation. (I poked around in lib/vsprintf.c and I
couldn't see any cases where it might allocate memory, but it would be
particularly bad if there was any way to trigger an Oops.)

> ---
> =A0kernel/cpuset.c | =A0 10 +---------
> =A01 files changed, 1 insertions(+), 9 deletions(-)
>
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 10f1835..f13ff2e 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1620,20 +1620,12 @@ static int cpuset_sprintf_cpulist(char *page, str=
uct cpuset *cs)
>
> =A0static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
> =A0{
> - =A0 =A0 =A0 NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
> =A0 =A0 =A0 =A0int retval;
>
> - =A0 =A0 =A0 if (mask =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> -

And this was particularly broken since the only caller of
cpuset_sprintf_memlist() doesn't handle a negative error response
anyway and would then overwrite byte 4083 on the preceding page with a
'\n'. And then since the (size_t)(s-page) that's passed to
simple_read_from_buffer() would be a very large number, it would write
arbitrary (user-controlled) amounts of kernel data to the userspace
buffer.

Maybe we could also rename 'retval' to 'count' in this function (and
cpuset_sprintf_cpulist()) to make it clearer that callers don't expect
negative error values?

> =A0 =A0 =A0 =A0mutex_lock(&callback_mutex);
> - =A0 =A0 =A0 *mask =3D cs->mems_allowed;
> + =A0 =A0 =A0 retval =3D nodelist_scnprintf(page, PAGE_SIZE, cs->mems_all=
owed);
> =A0 =A0 =A0 =A0mutex_unlock(&callback_mutex);
>
> - =A0 =A0 =A0 retval =3D nodelist_scnprintf(page, PAGE_SIZE, *mask);
> -
> - =A0 =A0 =A0 NODEMASK_FREE(mask);
> -
> =A0 =A0 =A0 =A0return retval;
> =A0}
>
> --
> 1.7.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
