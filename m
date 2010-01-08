Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12CBC6B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 20:05:41 -0500 (EST)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id o0815d7r032155
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 17:05:39 -0800
Received: from qw-out-2122.google.com (qwh8.prod.google.com [10.241.194.200])
	by spaceape11.eur.corp.google.com with ESMTP id o0815bm2025180
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 17:05:38 -0800
Received: by qw-out-2122.google.com with SMTP id 8so1453915qwh.41
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 17:05:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B46828C.5000703@cn.fujitsu.com>
References: <cover.1262186097.git.kirill@shutemov.name>
	 <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
	 <6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com>
	 <cc557aab1001070436w446ef85n55dd2af5e733f55e@mail.gmail.com>
	 <4B46828C.5000703@cn.fujitsu.com>
Date: Thu, 7 Jan 2010 17:05:37 -0800
Message-ID: <6599ad831001071705k3954642eo3e04cef7a31e3727@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.linux-foundation.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 7, 2010 at 4:55 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> Use multi labels is much better:

I disagree with that - in the absence of a language that can do proper
destructor-based cleanup (i.e. a strictly controlled subset of C++ :-)
) I think it's clearer to have a single failure path where you can
clean up anything that needs to be cleaned up, without excessive
dependencies on exactly when the failure occurred. Changes then become
less error-prone.

Paul

>
> label4::
> =A0 =A0 =A0 =A0fput(cfile);
> label3:
> =A0 =A0 =A0 =A0eventfd_ctx_put(event->eventfd);
> label2:
> =A0 =A0 =A0 =A0fput(efile);
> label1:
> =A0 =A0 =A0 =A0kfree(event);
>
> compared to:
>
> +fail:
> + =A0 =A0 =A0 if (!IS_ERR(cfile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(cfile);
> +
> + =A0 =A0 =A0 if (event && event->eventfd && !IS_ERR(event->eventfd))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 eventfd_ctx_put(event->eventfd);
> +
> + =A0 =A0 =A0 if (!IS_ERR(efile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(efile);
> +
> + =A0 =A0 =A0 kfree(event);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
