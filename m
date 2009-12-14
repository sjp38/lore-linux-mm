Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 882B56B003D
	for <linux-mm@kvack.org>; Sun, 13 Dec 2009 19:14:40 -0500 (EST)
Received: by pwi1 with SMTP id 1so2062771pwi.6
        for <linux-mm@kvack.org>; Sun, 13 Dec 2009 16:14:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091211164651.036f5340@annuminas.surriel.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
Date: Mon, 14 Dec 2009 09:14:39 +0900
Message-ID: <28c262360912131614h62d8e0f7qf6ea9ab882f446d4@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Rik.

On Sat, Dec 12, 2009 at 6:46 AM, Rik van Riel <riel@redhat.com> wrote:
> Under very heavy multi-process workloads, like AIM7, the VM can
> get into trouble in a variety of ways. =C2=A0The trouble start when
> there are hundreds, or even thousands of processes active in the
> page reclaim code.
>
> Not only can the system suffer enormous slowdowns because of
> lock contention (and conditional reschedules) between thousands
> of processes in the page reclaim code, but each process will try
> to free up to SWAP_CLUSTER_MAX pages, even when the system already
> has lots of memory free.
>
> It should be possible to avoid both of those issues at once, by
> simply limiting how many processes are active in the page reclaim
> code simultaneously.
>
> If too many processes are active doing page reclaim in one zone,
> simply go to sleep in shrink_zone().
>
> On wakeup, check whether enough memory has been freed already
> before jumping into the page reclaim code ourselves. =C2=A0We want
> to use the same threshold here that is used in the page allocator
> for deciding whether or not to call the page reclaim code in the
> first place, otherwise some unlucky processes could end up freeing
> memory for the rest of the system.

I am worried about one.

Now, we can put too many processes reclaim_wait with NR_UNINTERRUBTIBLE sta=
te.
If OOM happens, OOM will kill many innocent processes since
uninterruptible task
can't handle kill signal until the processes free from reclaim_wait list.

I think reclaim_wait list staying time might be long if VM pressure is heav=
y.
Is this a exaggeration?

If it is serious problem, how about this?

We add new PF_RECLAIM_BLOCK flag and don't pick the process
in select_bad_process.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
