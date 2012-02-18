Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 90B056B0143
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 09:43:59 -0500 (EST)
Received: by vcbf13 with SMTP id f13so4112592vcb.14
        for <linux-mm@kvack.org>; Sat, 18 Feb 2012 06:43:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120218133904.GA1678@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
	<20120217182818.f3e7fe28.kamezawa.hiroyu@jp.fujitsu.com>
	<20120218133904.GA1678@cmpxchg.org>
Date: Sat, 18 Feb 2012 22:43:58 +0800
Message-ID: <CAJd=RBD=U1Uy_MnO9wL_Ag6M7tYUOfs=aSXV+sJabHWRNSSudQ@mail.gmail.com>
Subject: Re: [PATCH 5/6] memcg: remove PCG_FILE_MAPPED
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Sat, Feb 18, 2012 at 9:39 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Feb 17, 2012 at 06:28:18PM +0900, KAMEZAWA Hiroyuki wrote:
>> @@ -2559,7 +2555,7 @@ static int mem_cgroup_move_account(struct page *pa=
ge,
>>
>> =C2=A0 =C2=A0 =C2=A0 move_lock_mem_cgroup(from, &flags);
>>
>> - =C2=A0 =C2=A0 if (PageCgroupFileMapped(pc)) {
>> + =C2=A0 =C2=A0 if (page_mapped(page)) {
>
> As opposed to update_page_stat(), this runs against all types of
> pages, so I think it should be
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageAnon(page) && page_mapped(page))
>
> instead.
>
Perhaps the following helper or similar needed,
along with page_mapped()

static inline bool page_is_file_mapping(struct page *page)
{
	struct address_space *mapping =3D page_mapping(page);

	return mapping && mapping !=3D &swapper_space &&
		((unsigned long)mapping & PAGE_MAPPING_FLAGS) =3D=3D 0;
}

>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Update mapped_file d=
ata for mem_cgroup */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 preempt_disable();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __this_cpu_dec(from->st=
at->count[MEM_CGROUP_STAT_FILE_MAPPED]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
