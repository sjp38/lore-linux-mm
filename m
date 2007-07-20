Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l6KL9Im3006194
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 22:09:25 +0100
Received: from an-out-0708.google.com (andd31.prod.google.com [10.100.30.31])
	by zps38.corp.google.com with ESMTP id l6KL8se8020103
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:09:10 -0700
Received: by an-out-0708.google.com with SMTP id d31so214071and
        for <linux-mm@kvack.org>; Fri, 20 Jul 2007 14:09:10 -0700 (PDT)
Message-ID: <6599ad830707201409s30badabage2518dad09f17ae4@mail.gmail.com>
Date: Fri, 20 Jul 2007 14:09:09 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm PATCH 4/8] Memory controller memory accounting (v3)
In-Reply-To: <6599ad830707201403n6a364514y601996145fa3714c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	 <20070720082440.20752.67223.sendpatchset@balbir-laptop>
	 <6599ad830707201403n6a364514y601996145fa3714c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Eric W Biederman <ebiederm@xmission.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/20/07, Paul Menage <menage@google.com> wrote:
> > +       mem = rcu_dereference(mm->mem_container);
> > +       /*
> > +        * For every charge from the container, increment reference
> > +        * count
> > +        */
> > +       css_get(&mem->css);
> > +       rcu_read_unlock();
>
> It's not clear to me that this is safe.
>

Sorry, didn't finish this thought.

Right after the rcu_dereference() the mm could be moved to another
container by some other process.

Since there's an rcu_synchronize() after the movement, and the
rcu_synchronize() caller holds container_mutex then I guess it's not
possible for a third process to delete the container during the RCU
section, since it won't be able to acquire the mutex until after the
RCU read section completes. So OK, it is safe, at least based on the
guarantees made by the current implementation.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
