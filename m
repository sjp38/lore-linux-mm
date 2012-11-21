Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3EBD76B002B
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 04:26:05 -0500 (EST)
Message-ID: <50AC9E20.2060208@parallels.com>
Date: Wed, 21 Nov 2012 13:25:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
References: <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com> <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com> <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com> <50AA3FEF.2070100@parallels.com> <alpine.DEB.2.00.1211201013460.4200@chino.kir.corp.google.com> <50AC9070.2030009@parallels.com> <20121121084603.GA18159@lizard>
In-Reply-To: <20121121084603.GA18159@lizard>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 11/21/2012 12:46 PM, Anton Vorontsov wrote:
> On Wed, Nov 21, 2012 at 12:27:28PM +0400, Glauber Costa wrote:
>> On 11/20/2012 10:23 PM, David Rientjes wrote:
>>> Anton can correct me if I'm wrong, but I certainly don't think this is 
>>> where mempressure is headed: I don't think any accounting needs to be done
> 
> Yup, I'd rather not do any accounting, at least not in bytes.

It doesn't matter here, but memcg doesn't do any accounting in bytes as
well. It only display it in bytes, but internally, it's all pages. The
bytes representation is convenient, because then you can be agnostic of
page sizes.

> 
>>> and, if it is, it's a design issue that should be addressed now rather 
>>> than later.  I believe notifications should occur on current's mempressure 
>>> cgroup depending on its level of reclaim: nobody cares if your memcg has a 
>>> limit of 64GB when you only have 32GB of RAM, we'll want the notification.
>>
>> My main concern is that to trigger those notifications, one would have
>> to first determine whether or not the particular group of tasks is under
>> pressure.
> 
> As far as I understand, the notifications will be triggered by a process
> that tries to allocate memory. So, effectively that would be a per-process
> pressure.
> 
> So, if one process in a group is suffering, we notify that "a process in a
> group is under pressure", and the notification goes to a cgroup listener


If you effectively have a per-process mechanism, why do you need an
extra cgroup at all?

It seems to me that this is simply something that should be inherited
over fork, and then you register the notifier in your first process, and
it will be valid for everybody in the process tree.

If you need tasks in different processes to respond to the same
notifier, then you just register the same notifier in two different
processes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
