From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Fri, 04 Apr 2008 00:04:39 +0530
Message-ID: <47F5233F.1010108@linux.vnet.ibm.com>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain> <6599ad830804031058l1e2a7ad9p56cff47dca738d79@mail.gmail.com> <47F51DE7.7010204@linux.vnet.ibm.com> <6599ad830804031122y3f6946fbp97dc18073bf02609@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760549AbYDCSfW@vger.kernel.org>
In-Reply-To: <6599ad830804031122y3f6946fbp97dc18073bf02609@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Thu, Apr 3, 2008 at 11:11 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >
>>  > Hmm, is this new check for delay_group_leader() safe? Won't we have
>>  > called exit_cgroup() by this point, and hence be reassigned to the
>>  > root cgroup? And so mm->owner->cgroups won't point to the right place?
>>  >
>>
>>  cgroup_exit() comes in much later after exit_mm(). Moreover delay_group_leader()
>>  is a function that checks to see if
> 
> Sorry, I was unclear.
> 
> Yes, the call to cgroup_exit() comes much later than exit_mm() - but
> it probably does come before the other users of the mm have finished
> using the mm. So can't we end up with a situation like this?
> 
> A (group leader) exits; at this point, A->mm->owner == A
> A calls exit_mm(), sees delay_group_leader(), doesn't change A->mm->owner
> A calls cgroup_exit(), A->cgroups is set to init_css_set.
> B (another thread) does something with B->mm->owner->cgroups (e.g. VM
> accounting) and accesses the wrong group

Hi, Paul,

That is indeed quite bad. Do we have to retire the group_leader to init_css_set?
Can we not check for delay_group_leader() there?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
