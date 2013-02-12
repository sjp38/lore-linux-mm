Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 7F4266B0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 11:41:33 -0500 (EST)
In-Reply-To: <20130212162442.GJ4863@dhcp22.suse.cz>
References: <20130211151649.GD19922@dhcp22.suse.cz> <20130211175619.GC13218@cmpxchg.org> <20130211192929.GB29000@dhcp22.suse.cz> <20130211195824.GB15951@cmpxchg.org> <20130211212756.GC29000@dhcp22.suse.cz> <20130211223943.GC15951@cmpxchg.org> <20130212095419.GB4863@dhcp22.suse.cz> <20130212151002.GD15951@cmpxchg.org> <20130212154330.GG4863@dhcp22.suse.cz> <20130212161332.GI4863@dhcp22.suse.cz> <20130212162442.GJ4863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 12 Feb 2013 11:41:03 -0500
Message-ID: <63d3b5fa-dbc6-4bc9-8867-f9961e644305@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>



Michal Hocko <mhocko@suse.cz> wrote:

>On Tue 12-02-13 17:13:32, Michal H=
ocko wrote:
>> On Tue 12-02-13 16:43:30, Michal Hocko wrote:
>> [...]
>> Th=
e example was not complete:
>> 
>> > Wait a moment. But what prevents from =
the following race?
>> > 
>> > rcu_read_lock()
>> 
>> cgroup_next_descendan=
t_pre
>> css_tryget(css);
>> memcg =3D mem_cgroup_from_css(css)		atomic_add=
(CSS_DEACT_BIAS,
>&css->refcnt)
>> 
>> > 						mem_cgroup_css_offline(memcg=
)
>> 
>> We should be safe if we did synchronize_rcu() before
>root->dead_c=
ount++,
>> no?
>> Because then we would have a guarantee that if css_tryget=
(memcg)
>> suceeded then we wouldn't race with dead_count++ it triggered.
>=
> 
>> > 						root->dead_count++
>> > iter->last_dead_count =3D root->dead_=
count
>> > iter->last_visited =3D memcg
>> > 						// final
>> > 						css_=
put(memcg);
>> > // last_visited is still valid
>> > rcu_read_unlock()
>> >=
 [...]
>> > // next iteration
>> > rcu_read_lock()
>> > iter->last_dead_cou=
nt =3D=3D root->dead_count
>> > // KABOOM
>
>Ohh I have missed that we took=
 a reference on the current memcg which
>will be stored into last_visited. =
And then later, during the next
>iteration it will be still alive until we =
are done because previous
>patch moved css_put to the very end.
>So this ra=
ce is not possible. I still need to think about parallel
>iteration and a r=
ace with removal.

I thought the whole point was to not have a reference in=
 last_visited because have the iterator might be unused indefinitely :-)

W=
e only store a pointer and validate it before use the next time around.  So=
 I think the race is still possible, but we can deal with it by not losing =
concurrent dead count changes, i.e. one atomic read in the iterator functio=
n.

-- 
Sent from my Android phone with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
