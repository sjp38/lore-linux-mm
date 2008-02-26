Date: Tue, 26 Feb 2008 15:59:44 +0900 (JST)
Message-Id: <20080226.155944.54609943.taka@valinux.co.jp>
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <47C38127.2000109@cn.fujitsu.com>
References: <47C2FCC1.7090203@linux.vnet.ibm.com>
	<47C30EDC.4060005@google.com>
	<47C38127.2000109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lizf@cn.fujitsu.com
Cc: menage@google.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi,

> >>> I'll send out a prototype for comment.
> > 
> > Something like the patch below. The effects of cgroup_disable=foo are:
> > 
> > - foo doesn't show up in /proc/cgroups
> 
> Or we can print out the disable flag, maybe this will be better?
> Because we can distinguish from disabled and not compiled in from
> /proc/cgroups.

It would be neat if the disable flag /proc/cgroups can be cleared/set
on demand. It will depend on the implementation of each controller
whether it works or not.

> > - foo isn't auto-mounted if you mount all cgroups in a single hierarchy
> > - foo isn't visible as an individually mountable subsystem
> 
> You mentioned in a previous mail if we mount a disabled subsystem we
> will get an error. Here we just ignore the mount option. Which makes
> more sense ?
> 
> > 
> > As a result there will only ever be one call to foo->create(), at init
> > time; all processes will stay in this group, and the group will never be
> > mounted on a visible hierarchy. Any additional effects (e.g. not
> > allocating metadata) are up to the foo subsystem.
> > 
> > This doesn't handle early_init subsystems (their "disabled" bit isn't
> > set be, but it could easily be extended to do so if any of the
> > early_init systems wanted it - I think it would just involve some
> > nastier parameter processing since it would occur before the
> > command-line argument parser had been run.
> > 
> > include/linux/cgroup.h |    1 +
> > kernel/cgroup.c        |   29 +++++++++++++++++++++++++++--
> > 2 files changed, 28 insertions(+), 2 deletions(-)
> > 
> > Index: cgroup_disable-2.6.25-rc2-mm1/include/linux/cgroup.h
> > ===================================================================
> > --- cgroup_disable-2.6.25-rc2-mm1.orig/include/linux/cgroup.h
> > +++ cgroup_disable-2.6.25-rc2-mm1/include/linux/cgroup.h
> > @@ -256,6 +256,7 @@ struct cgroup_subsys {
> >     void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
> >     int subsys_id;
> >     int active;
> > +    int disabled;
> >     int early_init;
> > #define MAX_CGROUP_TYPE_NAMELEN 32
> >     const char *name;
> > Index: cgroup_disable-2.6.25-rc2-mm1/kernel/cgroup.c
> > ===================================================================
> > --- cgroup_disable-2.6.25-rc2-mm1.orig/kernel/cgroup.c
> > +++ cgroup_disable-2.6.25-rc2-mm1/kernel/cgroup.c
> > @@ -790,7 +790,14 @@ static int parse_cgroupfs_options(char *
> >         if (!*token)
> >             return -EINVAL;
> >         if (!strcmp(token, "all")) {
> > -            opts->subsys_bits = (1 << CGROUP_SUBSYS_COUNT) - 1;
> > +            /* Add all non-disabled subsystems */
> > +            int i;
> > +            opts->subsys_bits = 0;
> > +            for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> > +                struct cgroup_subsys *ss = subsys[i];
> > +                if (!ss->disabled)
> > +                    opts->subsys_bits |= 1ul << i;
> > +            }
> >         } else if (!strcmp(token, "noprefix")) {
> >             set_bit(ROOT_NOPREFIX, &opts->flags);
> >         } else if (!strncmp(token, "release_agent=", 14)) {
> > @@ -808,7 +815,8 @@ static int parse_cgroupfs_options(char *
> >             for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> >                 ss = subsys[i];
> >                 if (!strcmp(token, ss->name)) {
> > -                    set_bit(i, &opts->subsys_bits);
> > +                    if (!ss->disabled)
> > +                        set_bit(i, &opts->subsys_bits);
> >                     break;
> >                 }
> >             }
> > @@ -2596,6 +2606,8 @@ static int proc_cgroupstats_show(struct
> >     mutex_lock(&cgroup_mutex);
> >     for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> >         struct cgroup_subsys *ss = subsys[i];
> > +        if (ss->disabled)
> > +            continue;
> >         seq_printf(m, "%s\t%lu\t%d\n",
> >                ss->name, ss->root->subsys_bits,
> >                ss->root->number_of_cgroups);
> > @@ -2991,3 +3003,16 @@ static void cgroup_release_agent(struct
> >     spin_unlock(&release_list_lock);
> >     mutex_unlock(&cgroup_mutex);
> > }
> > +
> > +static int __init cgroup_disable(char *str)
> > +{
> > +    int i;
> > +    for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> > +        struct cgroup_subsys *ss = subsys[i];
> > +        if (!strcmp(str, ss->name)) {
> > +            ss->disabled = 1;
> > +            break;
> > +        }
> > +    }
> > +}
> > +__setup("cgroup_disable=", cgroup_disable);
> > 
> > 
> >>
> >> Sure thing, if css has the flag, then it would nice. Could you wrap it
> >> up to say
> >> something like css_disabled(&mem_cgroup_subsys)
> >>
> >>
> > 
> > It's the subsys object rather than the css (cgroup_subsys_state).
> > 
> >  We could have something like:
> > 
> > #define cgroup_subsys_disabled(_ss) ((ss_)->disabled)
> > 
> > but I don't see that
> >  cgroup_subsys_disabled(&mem_cgroup_subsys)
> > is better than just putting
> > 
> >  mem_cgroup_subsys.disabled
> > 
> > Paul
> > 
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
