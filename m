Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 58D956B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 13:39:01 -0400 (EDT)
In-Reply-To: <20130517165712.GB12632@mtj.dyndns.org>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz> <1368431172-6844-2-git-send-email-mhocko@suse.cz> <20130517160247.GA10023@cmpxchg.org> <20130517165712.GB12632@mtj.dyndns.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with zone shrinking code
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Fri, 17 May 2013 13:27:09 -0400
Message-ID: <b4e0e499-b922-4e9c-a0f8-02318ddf3b9b@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>



Tejun Heo <tj@kernel.org> wrote:

>Hello, Johannes.
>
>On Fri, May 17, 20=
13 at 12:02:47PM -0400, Johannes Weiner wrote:
>> There are setups with tho=
usands of groups that do not even use soft
>> limits.  Having them pointles=
sly iterate over all of them for every
>> couple of pages reclaimed is just=
 not acceptable.
>
>Hmmm... if the iteration is the problem, it shouldn't b=
e difficult to
>build list of children which should be iterated.  Would tha=
t make it
>acceptable?

You mean, a separate structure that tracks which gr=
oups are in excess of the limit?  Like the current tree? :)

Kidding aside,=
 yes, that would be better, and an unsorted list would probably be enough f=
or the global case.

To support target reclaim soft limits later on, we cou=
ld maybe propagate tags upwards the cgroup tree when a group is in excess s=
o that reclaim can be smarter about which subtrees to test for soft limits =
and which to skip during the soft limit pass.  The no-softlimit-set-anywher=
e case is then only a single tag test in the root cgroup.

But starting wit=
h the list would be simple enough, delete a bunch of code, come with the sa=
me performance improvements etc.
-- 
Sent from my Android phone with K-9 Ma=
il. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
