Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 9CFFB6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:24:56 -0500 (EST)
Received: by qafl39 with SMTP id l39so1770248qaf.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 16:24:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4D2459.3010908@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
	<4F4D2459.3010908@parallels.com>
Date: Tue, 28 Feb 2012 16:24:55 -0800
Message-ID: <CABCjUKDYUwR9FsjFW_Ea30zbvFx80-ObuN92_cNcUfGjPqWJiQ@mail.gmail.com>
Subject: Re: [PATCH 02/10] memcg: Uncharge all kmem when deleting a cgroup.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 11:00 AM, Glauber Costa <glommer@parallels.com> wrote:
> On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
>>
>> A later patch will also use this to move the accounting to the root
>> cgroup.
>>
>
> Suleiman,
>
> Did you do any measurements to figure out how long does it take, average,
> for dangling caches to go away ? Under memory pressure, let's say

Unfortunately, I don't have any such measurements, other than a very artificial:

# mkdir /dev/cgroup/memory/c
# echo 1073741824 > /dev/cgroup/memory/c/memory.limit_in_bytes
# sync && echo 3 > /proc/sys/vm/drop_caches
# echo $$ > /dev/cgroup/memory/c/tasks
# find / > /dev/null
# grep '(c)' /proc/slabinfo | wc -l
42
# echo $$ > /dev/cgroup/memory/tasks
# rmdir /dev/cgroup/memory/c
# grep '(c)dead' /proc/slabinfo | wc -l
42
# sleep 60 && sync && for i in `seq 1 1000`; do echo 3 >
/proc/sys/vm/drop_caches ; done
# grep '(c)dead' /proc/slabinfo | wc -l
6
# sleep 60 && grep '(c)dead' /proc/slabinfo | wc -l
5
# sleep 60 && grep '(c)dead' /proc/slabinfo | wc -l
5

(Note that this is without any per-memcg shrinking patch applied. With
shrinking, things will be a bit better, because deleting the cgroup
will force the dentries to get shrunk.)

Some of these dead caches may take a long time to go away, but we
haven't found them to be a problem for us, so far.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
