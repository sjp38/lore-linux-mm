From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Fri, 04 Apr 2008 13:58:12 +0530
Message-ID: <47F5E69C.9@linux.vnet.ibm.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain> <6599ad830804040112q3dd5333aodf6a170c78e61dc8@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758733AbYDDI3Q@vger.kernel.org>
In-Reply-To: <6599ad830804040112q3dd5333aodf6a170c78e61dc8@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Fri, Apr 4, 2008 at 1:05 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  After the thread group leader exits, it's moved to init_css_state by
>>  cgroup_exit(), thus all future charges from runnings threads would
>>  be redirected to the init_css_set's subsystem.
> 
> And its uncharges, which is more of the problem I was getting at
> earlier - surely when the mm is finally destroyed, all its virtual
> address space charges will be uncharged from the root cgroup rather
> than the correct cgroup, if we left the delayed group leader as the
> owner? Which is why I think the group leader optimization is unsafe.

It won't uncharge for the memory controller from the root cgroup since each page
 has the mem_cgroup information associated with it. For other controllers,
they'll need to monitor exit() callbacks to know when the leader is dead :( (sigh).

Not having the group leader optimization can introduce big overheads (consider
thousands of tasks, with the group leader being the first one to exit).

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
