Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 91A856B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 17:09:42 -0500 (EST)
Received: by wmvv187 with SMTP id v187so228393639wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:09:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cm4si76629764wjb.78.2015.12.01.14.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 14:09:40 -0800 (PST)
Date: Tue, 1 Dec 2015 14:09:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151201140937.e07922d9a9404ae0c184cd7f@linux-foundation.org>
In-Reply-To: <87610jugw4.fsf@x220.int.ebiederm.org>
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
	<1448578785-17656-2-git-send-email-dcashman@android.com>
	<20151130155412.b1a087f4f6f4d4180ab4472d@linux-foundation.org>
	<20151130160118.e43a2e53a59e347a95a94d5c@linux-foundation.org>
	<CAGXu5jK7UzjBxXKQajxhLv-uLk_xQXR_FHOsmW6RLJNeK_-dZg@mail.gmail.com>
	<20151130161811.592c205d8dc7b00f44066a37@linux-foundation.org>
	<87610jugw4.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Kees Cook <keescook@chromium.org>, Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Mon, 30 Nov 2015 18:55:23 -0600 ebiederm@xmission.com (Eric W. Biederman) wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Mon, 30 Nov 2015 16:04:36 -0800 Kees Cook <keescook@chromium.org> wrote:
> >
> >> >> > +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
> >> >> > +   {
> >> >> > +           .procname       = "mmap_rnd_bits",
> >> >> > +           .data           = &mmap_rnd_bits,
> >> >> > +           .maxlen         = sizeof(mmap_rnd_bits),
> >> >> > +           .mode           = 0600,
> >> >> > +           .proc_handler   = proc_dointvec_minmax,
> >> >> > +           .extra1         = (void *) &mmap_rnd_bits_min,
> >> >> > +           .extra2         = (void *) &mmap_rnd_bits_max,
> >> >>
> >> >> hm, why the typecasts?  They're unneeded and are omitted everywhere(?)
> >> >> else in kernel/sysctl.c.
> >> >
> >> > Oh.  Casting away constness.
> >> >
> >> > What's the thinking here?  They can change at any time so they aren't
> >> > const so we shouldn't declare them to be const?
> >> 
> >> The _min and _max values shouldn't be changing: they're decided based
> >> on the various CONFIG options that calculate the valid min/maxes. Only
> >> mmap_rnd_bits itself should be changing.
> >
> > hmpf.
> >
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: include/linux/sysctl.h: make ctl_table.extra1/2 const
> >
> > Nothing should be altering these values.  Declare the pointed-to values to
> > be const so we can actually use const values.
> 
> No large objects except we do seem to have values that are stashed
> in extra1 that are cast to non-const types.
> 
> Any chance you will do the work to hunt all of those down and modify
> the casts to preserve const or to remove the casts entirely?

Below.  Most of it, anyway.

net is doing weird stuff, stashing very-much-non-const things into
extra1 and extra2.  I don't see much point in sprinkling casts
everywhere to conceal this (ab)use.  extra1 and extra2 clearly aren't
const, so I think I'll give up and sulk.


 drivers/parport/procfs.c       |    4 ++--
 net/core/neighbour.c           |    6 +++---
 net/decnet/dn_dev.c            |    2 +-
 net/ipv4/devinet.c             |   10 +++++-----
 net/ipv6/addrconf.c            |   12 +++++++-----
 net/ipv6/ndisc.c               |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 7 files changed, 20 insertions(+), 18 deletions(-)

diff -puN net/core/neighbour.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/core/neighbour.c
--- a/net/core/neighbour.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/core/neighbour.c
@@ -2915,8 +2915,8 @@ static void neigh_copy_dflt_parms(struct
 
 static void neigh_proc_update(struct ctl_table *ctl, int write)
 {
-	struct net_device *dev = ctl->extra1;
-	struct neigh_parms *p = ctl->extra2;
+	struct net_device *dev = (void *)ctl->extra1;
+	struct neigh_parms *p = (void *)ctl->extra2;
 	struct net *net = neigh_parms_net(p);
 	int index = (int *) ctl->data - p->data;
 
@@ -2999,7 +2999,7 @@ static int neigh_proc_base_reachable_tim
 					  void __user *buffer,
 					  size_t *lenp, loff_t *ppos)
 {
-	struct neigh_parms *p = ctl->extra2;
+	struct neigh_parms *p = (void *)ctl->extra2;
 	int ret;
 
 	if (strcmp(ctl->procname, "base_reachable_time") == 0)
diff -puN net/decnet/dn_dev.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/decnet/dn_dev.c
--- a/net/decnet/dn_dev.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/decnet/dn_dev.c
@@ -248,7 +248,7 @@ static int dn_forwarding_proc(struct ctl
 				size_t *lenp, loff_t *ppos)
 {
 #ifdef CONFIG_DECNET_ROUTER
-	struct net_device *dev = table->extra1;
+	struct net_device *dev = (void *)table->extra1;
 	struct dn_dev *dn_db;
 	int err;
 	int tmp, old;
diff -puN net/ipv4/devinet.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/ipv4/devinet.c
--- a/net/ipv4/devinet.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/ipv4/devinet.c
@@ -2030,8 +2030,8 @@ static int devinet_conf_proc(struct ctl_
 	int new_value = *(int *)ctl->data;
 
 	if (write) {
-		struct ipv4_devconf *cnf = ctl->extra1;
-		struct net *net = ctl->extra2;
+		struct ipv4_devconf *cnf = (void *)ctl->extra1;
+		struct net *net = (void *)ctl->extra2;
 		int i = (int *)ctl->data - cnf->data;
 		int ifindex;
 
@@ -2077,7 +2077,7 @@ static int devinet_sysctl_forward(struct
 	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	if (write && *valp != val) {
-		struct net *net = ctl->extra2;
+		struct net *net = (void *)ctl->extra2;
 
 		if (valp != &IPV4_DEVCONF_DFLT(net, FORWARDING)) {
 			if (!rtnl_trylock()) {
@@ -2089,7 +2089,7 @@ static int devinet_sysctl_forward(struct
 			if (valp == &IPV4_DEVCONF_ALL(net, FORWARDING)) {
 				inet_forward_change(net);
 			} else {
-				struct ipv4_devconf *cnf = ctl->extra1;
+				struct ipv4_devconf *cnf = (void *)ctl->extra1;
 				struct in_device *idev =
 					container_of(cnf, struct in_device, cnf);
 				if (*valp)
@@ -2117,7 +2117,7 @@ static int ipv4_doint_and_flush(struct c
 	int *valp = ctl->data;
 	int val = *valp;
 	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
-	struct net *net = ctl->extra2;
+	struct net *net = (void *)ctl->extra2;
 
 	if (write && *valp != val)
 		rt_cache_flush(net);
diff -puN net/ipv6/addrconf.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/ipv6/addrconf.c
@@ -5203,7 +5203,7 @@ static
 int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct inet6_dev *idev = ctl->extra1;
+	const struct inet6_dev *idev = ctl->extra1;
 	int min_mtu = IPV6_MIN_MTU;
 	struct ctl_table lctl;
 
@@ -5312,7 +5312,7 @@ int addrconf_sysctl_proxy_ndp(struct ctl
 	new = *valp;
 
 	if (write && old != new) {
-		struct net *net = ctl->extra2;
+		struct net *net = (struct net *)ctl->extra2;
 
 		if (!rtnl_trylock())
 			return restart_syscall();
@@ -5326,8 +5326,9 @@ int addrconf_sysctl_proxy_ndp(struct ctl
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
 		else {
-			struct inet6_dev *idev = ctl->extra1;
+			struct inet6_dev *idev;
 
+			idev = (struct inet6_dev *)ctl->extra1;
 			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						     idev->dev->ifindex,
 						     &idev->cnf);
@@ -5346,7 +5347,7 @@ static int addrconf_sysctl_stable_secret
 	struct in6_addr addr;
 	char str[IPV6_MAX_STRLEN];
 	struct ctl_table lctl = *ctl;
-	struct net *net = ctl->extra2;
+	const struct net *net = ctl->extra2;
 	struct ipv6_stable_secret *secret = ctl->data;
 
 	if (&net->ipv6.devconf_all->stable_secret == ctl->data)
@@ -5396,8 +5397,9 @@ static int addrconf_sysctl_stable_secret
 			}
 		}
 	} else {
-		struct inet6_dev *idev = ctl->extra1;
+		struct inet6_dev *idev;
 
+		idev = (struct inet6_dev *)ctl->extra1;
 		idev->addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	}
 
diff -puN net/ipv6/ndisc.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/ipv6/ndisc.c
@@ -1738,7 +1738,7 @@ static void ndisc_warn_deprecated_sysctl
 
 int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct net_device *dev = ctl->extra1;
+	const struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
 	int ret;
 
diff -puN net/netfilter/ipvs/ip_vs_ctl.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix net/netfilter/ipvs/ip_vs_ctl.c
--- a/net/netfilter/ipvs/ip_vs_ctl.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1608,7 +1608,7 @@ static int
 proc_do_defense_mode(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct netns_ipvs *ipvs = table->extra2;
+	struct netns_ipvs *ipvs = (void *)table->extra2;
 	int *valp = table->data;
 	int val = *valp;
 	int rc;
diff -puN drivers/parport/procfs.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix drivers/parport/procfs.c
--- a/drivers/parport/procfs.c~include-linux-sysctlh-make-ctl_tableextra1-2-const-fix
+++ a/drivers/parport/procfs.c
@@ -35,7 +35,7 @@
 static int do_active_device(struct ctl_table *table, int write,
 		      void __user *result, size_t *lenp, loff_t *ppos)
 {
-	struct parport *port = (struct parport *)table->extra1;
+	const struct parport *port = table->extra1;
 	char buffer[256];
 	struct pardevice *dev;
 	int len = 0;
@@ -72,7 +72,7 @@ static int do_active_device(struct ctl_t
 static int do_autoprobe(struct ctl_table *table, int write,
 			void __user *result, size_t *lenp, loff_t *ppos)
 {
-	struct parport_device_info *info = table->extra2;
+	const struct parport_device_info *info = table->extra2;
 	const char *str;
 	char buffer[256];
 	int len = 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
