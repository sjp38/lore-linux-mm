Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DCCE06B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 03:11:45 -0500 (EST)
Message-ID: <511B4ACF.90209@parallels.com>
Date: Wed, 13 Feb 2013 12:11:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
References: <20130211195824.GB15951@cmpxchg.org> <20130211212756.GC29000@dhcp22.suse.cz> <20130211223943.GC15951@cmpxchg.org> <20130212095419.GB4863@dhcp22.suse.cz> <20130212151002.GD15951@cmpxchg.org> <20130212154330.GG4863@dhcp22.suse.cz> <20130212161332.GI4863@dhcp22.suse.cz> <20130212162442.GJ4863@dhcp22.suse.cz> <63d3b5fa-dbc6-4bc9-8867-f9961e644305@email.android.com> <20130212171216.GA17663@dhcp22.suse.cz> <20130212173741.GD25235@cmpxchg.org>
In-Reply-To: <20130212173741.GD25235@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>

On 02/12/2013 09:37 PM, Johannes Weiner wrote:
>> > All reads from root->dead_count are atomic already, so I am not sure
>> > what you mean here. Anyway, I hope I won't make this even more confusing
>> > if I post what I have right now:
> Yes, but we are doing two reads.  Can't the memcg that we'll store in
> last_visited be offlined during this and be freed after we drop the
> rcu read lock?  If we had just one read, we would detect this
> properly.
> 

I don't want to add any more confusion to an already fun discussion, but
IIUC, you are trying to avoid triggering a second round of reclaim in an
already dead memcg, right?

Can't you generalize the mechanism I use for kmemcg, where a very
similar problem exists ? This is how it looks like:


  /* this atomically sets a bit in the memcg. It does so
   * unconditionally, and it is (so far) okay if it is set
   * twice
   */
  memcg_kmem_mark_dead(memcg);

  /*
   * Then if kmem charges is not zero, we don't actually destroy the
   * memcg. The function where it lives will always be called when usage
   * reaches 0, so we guarantee that we will never miss the chance to
   * call the destruction function at least once.
   *
   * I suspect you could use a mechanism like this, or extend
   * this very same, to prevent the second reclaim to be even called
   */
  if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
          return;

  /*
   * this is how we guarantee that the destruction fuction is called at
   * most once. The second caller would see the bit unset.
   */
  if (memcg_kmem_test_and_clear_dead(memcg))
          mem_cgroup_put(memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
