Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0072B6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 02:18:32 -0500 (EST)
Received: by iyj17 with SMTP id 17so14683082iyj.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 23:18:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
	<20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
Date: Wed, 5 Jan 2011 16:18:27 +0900
Message-ID: <AANLkTikdkmf7+8S2wWqnaJnQZ7DizY4MFVVZAQtrxx0q@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 5, 2011 at 3:47 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Wed, 5 Jan 2011 13:48:50 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi,
>>
>> On Wed, Jan 5, 2011 at 1:00 PM, Daisuke Nishimura
>> <nishimura@mxp.nes.nec.co.jp> wrote:
>> > Hi.
>> >
>> > This is a fix for a problem which has bothered me for a month.
>> >
>> > =3D=3D=3D
>> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> >
>> > In current implimentation, mem_cgroup_end_migration() decides whether =
the page
>> > migration has succeeded or not by checking "oldpage->mapping".
>> >
>> > But if we are tring to migrate a shmem swapcache, the page->mapping of=
 it is
>> > NULL from the begining, so the check would be invalid.
>> > As a result, mem_cgroup_end_migration() assumes the migration has succ=
eeded
>> > even if it's not, so "newpage" would be freed while it's not uncharged=
