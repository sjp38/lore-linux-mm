Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEA1B6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 05:40:08 -0500 (EST)
Received: by qao25 with SMTP id 25so894326qao.14
        for <linux-mm@kvack.org>; Fri, 02 Dec 2011 02:40:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111202095646.GA21070@tiehlicka.suse.cz>
References: <1322818931-2674-1-git-send-email-lliubbo@gmail.com>
	<20111202095646.GA21070@tiehlicka.suse.cz>
Date: Fri, 2 Dec 2011 18:40:06 +0800
Message-ID: <CAA_GA1cVYx5nFC8ModyZCgUPfg3npJ3Kh47jFiRJvsYsj3Ykvg@mail.gmail.com>
Subject: Re: [PATCH] page_cgroup: add helper function to get swap_cgroup
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, jweiner@redhat.com, bsingharora@gmail.com

On Fri, Dec 2, 2011 at 5:56 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 02-12-11 17:42:11, Bob Liu wrote:
>> There are multi places need to get swap_cgroup, so add a helper
>> function:
>> static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent);
>> to simple the code.
>
> I like the cleanup but I guess we can do a little bit better ;)
>
> [...]
>> +static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent)
>
> Add struct swap_cgroup_ctrl ** ctrl parameter
>
>> +{
>> + =C2=A0 =C2=A0 int type =3D swp_type(ent);
>> + =C2=A0 =C2=A0 unsigned long offset =3D swp_offset(ent);
>> + =C2=A0 =C2=A0 unsigned long idx =3D offset / SC_PER_PAGE;
>> + =C2=A0 =C2=A0 unsigned long pos =3D offset & SC_POS_MASK;
>> + =C2=A0 =C2=A0 struct swap_cgroup_ctrl *ctrl;
>> + =C2=A0 =C2=A0 struct page *mappage;
>> + =C2=A0 =C2=A0 struct swap_cgroup *sc;
>> +
>> + =C2=A0 =C2=A0 ctrl =3D &swap_cgroup_ctrl[type];
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ctrl)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*ctrl =3D &swap_cg=
roup_ctrl[type]
>
> [...]
>> @@ -375,20 +393,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent=
,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned sho=
rt old, unsigned short new)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 int type =3D swp_type(ent);
>> - =C2=A0 =C2=A0 unsigned long offset =3D swp_offset(ent);
>> - =C2=A0 =C2=A0 unsigned long idx =3D offset / SC_PER_PAGE;
>> - =C2=A0 =C2=A0 unsigned long pos =3D offset & SC_POS_MASK;
>> =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup_ctrl *ctrl;
>> - =C2=A0 =C2=A0 struct page *mappage;
>> =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup *sc;
>> =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
>> =C2=A0 =C2=A0 =C2=A0 unsigned short retval;
>>
>> =C2=A0 =C2=A0 =C2=A0 ctrl =3D &swap_cgroup_ctrl[type];
>> + =C2=A0 =C2=A0 sc =3D swap_cgroup_getsc(ent);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc =3D swap_cgroup_getsc(ent, &ctrl);
> [...]
>> @@ -410,20 +422,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent=
,
>> =C2=A0unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short =
id)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 int type =3D swp_type(ent);
>> - =C2=A0 =C2=A0 unsigned long offset =3D swp_offset(ent);
>> - =C2=A0 =C2=A0 unsigned long idx =3D offset / SC_PER_PAGE;
>> - =C2=A0 =C2=A0 unsigned long pos =3D offset & SC_POS_MASK;
>> =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup_ctrl *ctrl;
>> - =C2=A0 =C2=A0 struct page *mappage;
>> =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup *sc;
>> =C2=A0 =C2=A0 =C2=A0 unsigned short old;
>> =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
>>
>> =C2=A0 =C2=A0 =C2=A0 ctrl =3D &swap_cgroup_ctrl[type];
>> + =C2=A0 =C2=A0 sc =3D swap_cgroup_getsc(ent);
>
> Same here
>
> [...]
>> @@ -440,21 +446,10 @@ unsigned short swap_cgroup_record(swp_entry_t ent,=
 unsigned short id)
>> =C2=A0 */
>> =C2=A0unsigned short lookup_swap_cgroup(swp_entry_t ent)
>> =C2=A0{
>> - =C2=A0 =C2=A0 int type =3D swp_type(ent);
>> - =C2=A0 =C2=A0 unsigned long offset =3D swp_offset(ent);
>> - =C2=A0 =C2=A0 unsigned long idx =3D offset / SC_PER_PAGE;
>> - =C2=A0 =C2=A0 unsigned long pos =3D offset & SC_POS_MASK;
>> - =C2=A0 =C2=A0 struct swap_cgroup_ctrl *ctrl;
>> - =C2=A0 =C2=A0 struct page *mappage;
>> =C2=A0 =C2=A0 =C2=A0 struct swap_cgroup *sc;
>> - =C2=A0 =C2=A0 unsigned short ret;
>>
>> - =C2=A0 =C2=A0 ctrl =3D &swap_cgroup_ctrl[type];
>> - =C2=A0 =C2=A0 mappage =3D ctrl->map[idx];
>> - =C2=A0 =C2=A0 sc =3D page_address(mappage);
>> - =C2=A0 =C2=A0 sc +=3D pos;
>> - =C2=A0 =C2=A0 ret =3D sc->id;
>> - =C2=A0 =C2=A0 return ret;
>> + =C2=A0 =C2=A0 sc =3D swap_cgroup_getsc(ent);
>> + =C2=A0 =C2=A0 return sc->id;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return swap_cgroup_getsc(ent, NULL)->id;
>
> What do you think?

Alright,  i'll send out v2.
Thanks for your review.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
