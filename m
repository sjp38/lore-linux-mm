From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 2 Apr 2008 09:31:57 +0900
Message-ID: <20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760040AbYDBA2L@vger.kernel.org>
In-Reply-To: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org


On Tue, 01 Apr 2008 18:13:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> +	/*
> +	 * Search in the children
> +	 */
> +	list_for_each_entry(c, &p->children, sibling) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	}
> +
This finds new owner when "current" is multi-threaded and
"current" called pthread_create(), right ?

> +	/*
> +	 * Search in the siblings
> +	 */
> +	list_for_each_entry(c, &p->parent->children, sibling) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	}
> +
This finds new owner when "current" is multi-threaded and
"current" is just a child (means it doesn't call pthread_create()) ?


> +	/*
> +	 * Search through everything else. We should not get
> +	 * here often
> +	 */
> +	do_each_thread(g, c) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	} while_each_thread(g, c);

Doing above in synchronized manner seems too heavy.
When this happen ? or Can this be done in lazy "on-demand" manner ?

+assign_new_owner:
+	rcu_read_unlock();
+	BUG_ON(c == p);
+	task_lock(c);
+	if (c->mm != mm) {
+		task_unlock(c);
+		goto retry;
+	}
+	cgroup_mm_owner_callbacks(mm->owner, c);
+	mm->owner = c;
+	task_unlock(c);
+}
Why rcu_read_unlock() before changing owner ? Is it safe ?

Thanks,
-Kame
