Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5089F8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:41:39 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2F2fYEL012275
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:41:34 -0700
Received: from qwh5 (qwh5.prod.google.com [10.241.194.197])
	by hpaq5.eem.corp.google.com with ESMTP id p2F2fFUf017480
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:41:33 -0700
Received: by qwh5 with SMTP id 5so110904qwh.20
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:41:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110314202324.GG31120@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <20110311171006.ec0d9c37.akpm@linux-foundation.org> <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 14 Mar 2011 19:41:13 -0700
Message-ID: <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Mon, Mar 14, 2011 at 1:23 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Mon, Mar 14, 2011 at 11:29:17AM -0700, Greg Thelen wrote:
>
> [..]
>> > We could just crawl the memcg's page LRU and bring things under contro=
l
>> > that way, couldn't we? =A0That would fix it. =A0What were the reasons =
for
>> > not doing this?
>>
>> My rational for pursuing bdi writeback was I/O locality. =A0I have heard=
 that
>> per-page I/O has bad locality. =A0Per inode bdi-style writeback should h=
ave better
>> locality.
>>
>> My hunch is the best solution is a hybrid which uses a) bdi writeback wi=
th a
>> target memcg filter and b) using the memcg lru as a fallback to identify=
 the bdi
>> that needed writeback. =A0I think the part a) memcg filtering is likely =
something
>> like:
>> =A0http://marc.info/?l=3Dlinux-kernel&m=3D129910424431837
>>
>> The part b) bdi selection should not be too hard assuming that page-to-m=
apping
>> locking is doable.
>
> Greg,
>
> IIUC, option b) seems to be going through pages of particular memcg and
> mapping page to inode and start writeback on particular inode?

Yes.

> If yes, this might be reasonably good. In the case when cgroups are not
> sharing inodes then it automatically maps one inode to one cgroup and
> once cgroup is over limit, it starts writebacks of its own inode.
>
> In case inode is shared, then we get the case of one cgroup writting
> back the pages of other cgroup. Well I guess that also can be handeled
> by flusher thread where a bunch or group of pages can be compared with
> the cgroup passed in writeback structure. I guess that might hurt us
> more than benefit us.

Agreed.  For now just writing the entire inode is probably fine.

> IIUC how option b) works then we don't even need option a) where an N lev=
el
> deep cache is maintained?

Originally I was thinking that bdi-wide writeback with memcg filter
was a good idea.  But this may be unnecessarily complex.  Now I am
agreeing with you that option (a) may not be needed.  Memcg could
queue per-inode writeback using the memcg lru to locate inodes
(lru->page->inode) with something like this in
[mem_cgroup_]balance_dirty_pages():

  while (memcg_usage() >=3D memcg_fg_limit) {
    inode =3D memcg_dirty_inode(cg);  /* scan lru for a dirty page, then
grab mapping & inode */
    sync_inode(inode, &wbc);
  }

  if (memcg_usage() >=3D memcg_bg_limit) {
    queue per-memcg bg flush work item
  }

Does this look sensible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
