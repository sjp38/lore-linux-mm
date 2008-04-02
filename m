From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 2 Apr 2008 12:27:38 -0700
Message-ID: <6599ad830804021227od74be74j696105eae67bd22a@mail.gmail.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
	 <20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com>
	 <47F2FCAE.7070401@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758957AbYDBT2a@vger.kernel.org>
In-Reply-To: <47F2FCAE.7070401@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Tue, Apr 1, 2008 at 8:25 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  > +assign_new_owner:
>  > +     rcu_read_unlock();
>  > +     BUG_ON(c == p);
>  > +     task_lock(c);
>  > +     if (c->mm != mm) {
>  > +             task_unlock(c);
>  > +             goto retry;
>  > +     }
>  > +     cgroup_mm_owner_callbacks(mm->owner, c);
>  > +     mm->owner = c;
>  > +     task_unlock(c);
>  > +}
>  > Why rcu_read_unlock() before changing owner ? Is it safe ?
>  >
>
>  It should be safe, since we take task_lock(), but to be doubly sure, we can drop
>  rcu read lock after taking the task_lock().
>

I agree with Kamezawa - the task can technically disappear as soon as
we leave the RCU critical section. (In practice, it'll only happen
with CONFIG_PREEMPT).

Paul
