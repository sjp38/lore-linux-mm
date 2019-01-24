Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E198E0086
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 07:58:34 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so6501900qte.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 04:58:34 -0800 (PST)
Received: from mail.emypeople.net (mail.emypeople.net. [216.220.167.73])
        by mx.google.com with ESMTP id 10si5547757qto.215.2019.01.24.04.58.32
        for <linux-mm@kvack.org>;
        Thu, 24 Jan 2019 04:58:32 -0800 (PST)
From: "Edwin Zimmerman" <edwin@211mainstreet.net>
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
In-Reply-To: <20190123110349.35882-2-keescook@chromium.org>
Subject: RE: [PATCH 1/3] treewide: Lift switch variables out of switches
Date: Thu, 24 Jan 2019 07:58:32 -0500
Message-ID: <000501d4b3e4$83dd2290$8b9767b0$@211mainstreet.net>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Kees Cook' <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Laura Abbott' <labbott@redhat.com>, 'Alexander Popov' <alex.popov@linux.com>, xen-devel@lists.xenproject.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, dev@openvswitch.org, linux-kbuild@vger.kernel.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wednesday, January 23, 2019 6:04 AM, Kees Cook wrote
>=20
> Variables declared in a switch statement before any case statements
> cannot be initialized, so move all instances out of the switches.
> After this, future always-initialized stack variables will work
> and not throw warnings like this:
>=20
> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> fs/fcntl.c:738:13: warning: statement will never be executed =
[-Wswitch-unreachable]
>    siginfo_t si;
>              ^~
>=20
> Signed-off-by: Kees Cook <keescook@chromium.org>

Reviewed by: Edwin Zimmerman <edwin@211mainstreet.net>

> ---
>  arch/x86/xen/enlighten_pv.c                   |  7 ++++---
>  drivers/char/pcmcia/cm4000_cs.c               |  2 +-
>  drivers/char/ppdev.c                          | 20 =
++++++++-----------
>  drivers/gpu/drm/drm_edid.c                    |  4 ++--
>  drivers/gpu/drm/i915/intel_display.c          |  2 +-
>  drivers/gpu/drm/i915/intel_pm.c               |  4 ++--
>  drivers/net/ethernet/intel/e1000/e1000_main.c |  3 ++-
>  drivers/tty/n_tty.c                           |  3 +--
>  drivers/usb/gadget/udc/net2280.c              |  5 ++---
>  fs/fcntl.c                                    |  3 ++-
>  mm/shmem.c                                    |  5 +++--
>  net/core/skbuff.c                             |  4 ++--
>  net/ipv6/ip6_gre.c                            |  4 ++--
>  net/ipv6/ip6_tunnel.c                         |  4 ++--
>  net/openvswitch/flow_netlink.c                |  7 +++----
>  security/tomoyo/common.c                      |  3 ++-
>  security/tomoyo/condition.c                   |  7 ++++---
>  security/tomoyo/util.c                        |  4 ++--
>  18 files changed, 45 insertions(+), 46 deletions(-)
>=20
> diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
> index c54a493e139a..a79d4b548a08 100644
> --- a/arch/x86/xen/enlighten_pv.c
> +++ b/arch/x86/xen/enlighten_pv.c
> @@ -907,14 +907,15 @@ static u64 xen_read_msr_safe(unsigned int msr, =
int *err)
>  static int xen_write_msr_safe(unsigned int msr, unsigned low, =
unsigned high)
>  {
>  	int ret;
> +#ifdef CONFIG_X86_64
> +	unsigned which;
> +	u64 base;
> +#endif
>=20
>  	ret =3D 0;
>=20
>  	switch (msr) {
>  #ifdef CONFIG_X86_64
> -		unsigned which;
> -		u64 base;
> -
>  	case MSR_FS_BASE:		which =3D SEGBASE_FS; goto set;
>  	case MSR_KERNEL_GS_BASE:	which =3D SEGBASE_GS_USER; goto set;
>  	case MSR_GS_BASE:		which =3D SEGBASE_GS_KERNEL; goto set;
> diff --git a/drivers/char/pcmcia/cm4000_cs.c =
b/drivers/char/pcmcia/cm4000_cs.c
> index 7a4eb86aedac..7211dc0e6f4f 100644
> --- a/drivers/char/pcmcia/cm4000_cs.c
> +++ b/drivers/char/pcmcia/cm4000_cs.c
> @@ -663,6 +663,7 @@ static void monitor_card(struct timer_list *t)
>  {
>  	struct cm4000_dev *dev =3D from_timer(dev, t, timer);
>  	unsigned int iobase =3D dev->p_dev->resource[0]->start;
> +	unsigned char flags0;
>  	unsigned short s;
>  	struct ptsreq ptsreq;
>  	int i, atrc;
> @@ -731,7 +732,6 @@ static void monitor_card(struct timer_list *t)
>  	}
>=20
>  	switch (dev->mstate) {
> -		unsigned char flags0;
>  	case M_CARDOFF:
>  		DEBUGP(4, dev, "M_CARDOFF\n");
>  		flags0 =3D inb(REG_FLAGS0(iobase));
> diff --git a/drivers/char/ppdev.c b/drivers/char/ppdev.c
> index 1ae77b41050a..d77c97e4f996 100644
> --- a/drivers/char/ppdev.c
> +++ b/drivers/char/ppdev.c
> @@ -359,14 +359,19 @@ static int pp_do_ioctl(struct file *file, =
unsigned int cmd, unsigned long arg)
>  	struct pp_struct *pp =3D file->private_data;
>  	struct parport *port;
>  	void __user *argp =3D (void __user *)arg;
> +	struct ieee1284_info *info;
> +	unsigned char reg;
> +	unsigned char mask;
> +	int mode;
> +	s32 time32[2];
> +	s64 time64[2];
> +	struct timespec64 ts;
> +	int ret;
>=20
>  	/* First handle the cases that don't take arguments. */
>  	switch (cmd) {
>  	case PPCLAIM:
>  	    {
> -		struct ieee1284_info *info;
> -		int ret;
> -
>  		if (pp->flags & PP_CLAIMED) {
>  			dev_dbg(&pp->pdev->dev, "you've already got it!\n");
>  			return -EINVAL;
> @@ -517,15 +522,6 @@ static int pp_do_ioctl(struct file *file, =
unsigned int cmd, unsigned long arg)
>=20
>  	port =3D pp->pdev->port;
>  	switch (cmd) {
> -		struct ieee1284_info *info;
> -		unsigned char reg;
> -		unsigned char mask;
> -		int mode;
> -		s32 time32[2];
> -		s64 time64[2];
> -		struct timespec64 ts;
> -		int ret;
> -
>  	case PPRSTATUS:
>  		reg =3D parport_read_status(port);
>  		if (copy_to_user(argp, &reg, sizeof(reg)))
> diff --git a/drivers/gpu/drm/drm_edid.c b/drivers/gpu/drm/drm_edid.c
> index b506e3622b08..8f93956c1628 100644
> --- a/drivers/gpu/drm/drm_edid.c
> +++ b/drivers/gpu/drm/drm_edid.c
> @@ -3942,12 +3942,12 @@ static void drm_edid_to_eld(struct =
drm_connector *connector, struct edid *edid)
>  		}
>=20
>  		for_each_cea_db(cea, i, start, end) {
> +			int sad_count;
> +
>  			db =3D &cea[i];
>  			dbl =3D cea_db_payload_len(db);
>=20
>  			switch (cea_db_tag(db)) {
> -				int sad_count;
> -
>  			case AUDIO_BLOCK:
>  				/* Audio Data Block, contains SADs */
>  				sad_count =3D min(dbl / 3, 15 - total_sad_count);
> diff --git a/drivers/gpu/drm/i915/intel_display.c =
b/drivers/gpu/drm/i915/intel_display.c
> index 3da9c0f9e948..aa1c2ebea456 100644
> --- a/drivers/gpu/drm/i915/intel_display.c
> +++ b/drivers/gpu/drm/i915/intel_display.c
> @@ -11341,6 +11341,7 @@ static bool =
check_digital_port_conflicts(struct drm_atomic_state *state)
>  	drm_for_each_connector_iter(connector, &conn_iter) {
>  		struct drm_connector_state *connector_state;
>  		struct intel_encoder *encoder;
> +		unsigned int port_mask;
>=20
>  		connector_state =3D drm_atomic_get_new_connector_state(state, =
connector);
>  		if (!connector_state)
> @@ -11354,7 +11355,6 @@ static bool =
check_digital_port_conflicts(struct drm_atomic_state *state)
>  		WARN_ON(!connector_state->crtc);
>=20
>  		switch (encoder->type) {
> -			unsigned int port_mask;
>  		case INTEL_OUTPUT_DDI:
>  			if (WARN_ON(!HAS_DDI(to_i915(dev))))
>  				break;
> diff --git a/drivers/gpu/drm/i915/intel_pm.c =
b/drivers/gpu/drm/i915/intel_pm.c
> index a26b4eddda25..c135fdec96b3 100644
> --- a/drivers/gpu/drm/i915/intel_pm.c
> +++ b/drivers/gpu/drm/i915/intel_pm.c
> @@ -478,9 +478,9 @@ static void vlv_get_fifo_size(struct =
intel_crtc_state *crtc_state)
>  	struct vlv_fifo_state *fifo_state =3D =
&crtc_state->wm.vlv.fifo_state;
>  	enum pipe pipe =3D crtc->pipe;
>  	int sprite0_start, sprite1_start;
> +	uint32_t dsparb, dsparb2, dsparb3;
>=20
>  	switch (pipe) {
> -		uint32_t dsparb, dsparb2, dsparb3;
>  	case PIPE_A:
>  		dsparb =3D I915_READ(DSPARB);
>  		dsparb2 =3D I915_READ(DSPARB2);
> @@ -1944,6 +1944,7 @@ static void vlv_atomic_update_fifo(struct =
intel_atomic_state *state,
>  	const struct vlv_fifo_state *fifo_state =3D
>  		&crtc_state->wm.vlv.fifo_state;
>  	int sprite0_start, sprite1_start, fifo_size;
> +	uint32_t dsparb, dsparb2, dsparb3;
>=20
>  	if (!crtc_state->fifo_changed)
>  		return;
> @@ -1969,7 +1970,6 @@ static void vlv_atomic_update_fifo(struct =
intel_atomic_state *state,
>  	spin_lock(&dev_priv->uncore.lock);
>=20
>  	switch (crtc->pipe) {
> -		uint32_t dsparb, dsparb2, dsparb3;
>  	case PIPE_A:
>  		dsparb =3D I915_READ_FW(DSPARB);
>  		dsparb2 =3D I915_READ_FW(DSPARB2);
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c =
b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 8fe9af0e2ab7..041062736845 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -3140,8 +3140,9 @@ static netdev_tx_t e1000_xmit_frame(struct =
sk_buff *skb,
>=20
>  		hdr_len =3D skb_transport_offset(skb) + tcp_hdrlen(skb);
>  		if (skb->data_len && hdr_len =3D=3D len) {
> +			unsigned int pull_size;
> +
>  			switch (hw->mac_type) {
> -				unsigned int pull_size;
>  			case e1000_82544:
>  				/* Make sure we have room to chop off 4 bytes,
>  				 * and that the end alignment will work out to
> diff --git a/drivers/tty/n_tty.c b/drivers/tty/n_tty.c
> index 5dc9686697cf..eafb39157281 100644
> --- a/drivers/tty/n_tty.c
> +++ b/drivers/tty/n_tty.c
> @@ -634,6 +634,7 @@ static size_t __process_echoes(struct tty_struct =
*tty)
>  	while (MASK(ldata->echo_commit) !=3D MASK(tail)) {
>  		c =3D echo_buf(ldata, tail);
>  		if (c =3D=3D ECHO_OP_START) {
> +			unsigned int num_chars, num_bs;
>  			unsigned char op;
>  			int no_space_left =3D 0;
>=20
> @@ -652,8 +653,6 @@ static size_t __process_echoes(struct tty_struct =
*tty)
>  			op =3D echo_buf(ldata, tail + 1);
>=20
>  			switch (op) {
> -				unsigned int num_chars, num_bs;
> -
>  			case ECHO_OP_ERASE_TAB:
>  				if (MASK(ldata->echo_commit) =3D=3D MASK(tail + 2))
>  					goto not_yet_stored;
> diff --git a/drivers/usb/gadget/udc/net2280.c =
b/drivers/usb/gadget/udc/net2280.c
> index e7dae5379e04..2b275a574e94 100644
> --- a/drivers/usb/gadget/udc/net2280.c
> +++ b/drivers/usb/gadget/udc/net2280.c
> @@ -2854,16 +2854,15 @@ static void ep_clear_seqnum(struct net2280_ep =
*ep)
>  static void handle_stat0_irqs_superspeed(struct net2280 *dev,
>  		struct net2280_ep *ep, struct usb_ctrlrequest r)
>  {
> +	struct net2280_ep *e;
>  	int tmp =3D 0;
> +	u16 status;
>=20
>  #define	w_value		le16_to_cpu(r.wValue)
>  #define	w_index		le16_to_cpu(r.wIndex)
>  #define	w_length	le16_to_cpu(r.wLength)
>=20
>  	switch (r.bRequest) {
> -		struct net2280_ep *e;
> -		u16 status;
> -
>  	case USB_REQ_SET_CONFIGURATION:
>  		dev->addressed_state =3D !w_value;
>  		goto usb3_delegate;
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 083185174c6d..0640b64ecdc2 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -725,6 +725,8 @@ static void send_sigio_to_task(struct task_struct =
*p,
>  			       struct fown_struct *fown,
>  			       int fd, int reason, enum pid_type type)
>  {
> +	kernel_siginfo_t si;
> +
>  	/*
>  	 * F_SETSIG can change ->signum lockless in parallel, make
>  	 * sure we read it once and use the same value throughout.
> @@ -735,7 +737,6 @@ static void send_sigio_to_task(struct task_struct =
*p,
>  		return;
>=20
>  	switch (signum) {
> -		kernel_siginfo_t si;
>  		default:
>  			/* Queue a rt signal with the appropriate fd as its
>  			   value.  We use SI_SIGIO as the source, not
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 6ece1e2fe76e..0b02624dd8b2 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1721,6 +1721,9 @@ static int shmem_getpage_gfp(struct inode =
*inode, pgoff_t index,
>  		swap_free(swap);
>=20
>  	} else {
> +		loff_t i_size;
> +		pgoff_t off;
> +
>  		if (vma && userfaultfd_missing(vma)) {
>  			*fault_type =3D handle_userfault(vmf, VM_UFFD_MISSING);
>  			return 0;
> @@ -1734,8 +1737,6 @@ static int shmem_getpage_gfp(struct inode =
*inode, pgoff_t index,
>  		if (shmem_huge =3D=3D SHMEM_HUGE_FORCE)
>  			goto alloc_huge;
>  		switch (sbinfo->huge) {
> -			loff_t i_size;
> -			pgoff_t off;
>  		case SHMEM_HUGE_NEVER:
>  			goto alloc_nohuge;
>  		case SHMEM_HUGE_WITHIN_SIZE:
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 26d848484912..7597b3fc9d21 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4506,9 +4506,9 @@ static __sum16 *skb_checksum_setup_ip(struct =
sk_buff *skb,
>  				      typeof(IPPROTO_IP) proto,
>  				      unsigned int off)
>  {
> -	switch (proto) {
> -		int err;
> +	int err;
>=20
> +	switch (proto) {
>  	case IPPROTO_TCP:
>  		err =3D skb_maybe_pull_tail(skb, off + sizeof(struct tcphdr),
>  					  off + MAX_TCP_HDR_LEN);
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index b1be67ca6768..9aee1add46c0 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -427,9 +427,11 @@ static int ip6gre_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
>  		       u8 type, u8 code, int offset, __be32 info)
>  {
>  	struct net *net =3D dev_net(skb->dev);
> +	struct ipv6_tlv_tnl_enc_lim *tel;
>  	const struct ipv6hdr *ipv6h;
>  	struct tnl_ptk_info tpi;
>  	struct ip6_tnl *t;
> +	__u32 teli;
>=20
>  	if (gre_parse_header(skb, &tpi, NULL, htons(ETH_P_IPV6),
>  			     offset) < 0)
> @@ -442,8 +444,6 @@ static int ip6gre_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
>  		return -ENOENT;
>=20
>  	switch (type) {
> -		struct ipv6_tlv_tnl_enc_lim *tel;
> -		__u32 teli;
>  	case ICMPV6_DEST_UNREACH:
>  		net_dbg_ratelimited("%s: Path to destination invalid or =
inactive!\n",
>  				    t->parms.name);
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 0c6403cf8b52..94ccc7a9037b 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -478,10 +478,12 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, =
struct inet6_skb_parm *opt,
>  	struct net *net =3D dev_net(skb->dev);
>  	u8 rel_type =3D ICMPV6_DEST_UNREACH;
>  	u8 rel_code =3D ICMPV6_ADDR_UNREACH;
> +	struct ipv6_tlv_tnl_enc_lim *tel;
>  	__u32 rel_info =3D 0;
>  	struct ip6_tnl *t;
>  	int err =3D -ENOENT;
>  	int rel_msg =3D 0;
> +	__u32 mtu, teli;
>  	u8 tproto;
>  	__u16 len;
>=20
> @@ -501,8 +503,6 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, =
struct inet6_skb_parm *opt,
>  	err =3D 0;
>=20
>  	switch (*type) {
> -		struct ipv6_tlv_tnl_enc_lim *tel;
> -		__u32 mtu, teli;
>  	case ICMPV6_DEST_UNREACH:
>  		net_dbg_ratelimited("%s: Path to destination invalid or =
inactive!\n",
>  				    t->parms.name);
> diff --git a/net/openvswitch/flow_netlink.c =
b/net/openvswitch/flow_netlink.c
> index 691da853bef5..dee2f9516ae8 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -2652,8 +2652,11 @@ static int validate_set(const struct nlattr *a,
>  			u8 mac_proto, __be16 eth_type, bool masked, bool log)
>  {
>  	const struct nlattr *ovs_key =3D nla_data(a);
> +	const struct ovs_key_ipv4 *ipv4_key;
> +	const struct ovs_key_ipv6 *ipv6_key;
>  	int key_type =3D nla_type(ovs_key);
>  	size_t key_len;
> +	int err;
>=20
>  	/* There can be only one key in a action */
>  	if (nla_total_size(nla_len(ovs_key)) !=3D nla_len(a))
> @@ -2671,10 +2674,6 @@ static int validate_set(const struct nlattr *a,
>  		return -EINVAL;
>=20
>  	switch (key_type) {
> -	const struct ovs_key_ipv4 *ipv4_key;
> -	const struct ovs_key_ipv6 *ipv6_key;
> -	int err;
> -
>  	case OVS_KEY_ATTR_PRIORITY:
>  	case OVS_KEY_ATTR_SKB_MARK:
>  	case OVS_KEY_ATTR_CT_MARK:
> diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
> index c598aa00d5e3..bedbd0518153 100644
> --- a/security/tomoyo/common.c
> +++ b/security/tomoyo/common.c
> @@ -1583,8 +1583,9 @@ static void tomoyo_read_domain(struct =
tomoyo_io_buffer *head)
>  	list_for_each_cookie(head->r.domain, &tomoyo_domain_list) {
>  		struct tomoyo_domain_info *domain =3D
>  			list_entry(head->r.domain, typeof(*domain), list);
> +		u8 i;
> +
>  		switch (head->r.step) {
> -			u8 i;
>  		case 0:
>  			if (domain->is_deleted &&
>  			    !head->r.print_this_domain_only)
> diff --git a/security/tomoyo/condition.c b/security/tomoyo/condition.c
> index 8d0e1b9c9c57..c10d903febe5 100644
> --- a/security/tomoyo/condition.c
> +++ b/security/tomoyo/condition.c
> @@ -787,10 +787,11 @@ bool tomoyo_condition(struct tomoyo_request_info =
*r,
>  		/* Check string expressions. */
>  		if (right =3D=3D TOMOYO_NAME_UNION) {
>  			const struct tomoyo_name_union *ptr =3D names_p++;
> +			struct tomoyo_path_info *symlink;
> +			struct tomoyo_execve *ee;
> +			struct file *file;
> +
>  			switch (left) {
> -				struct tomoyo_path_info *symlink;
> -				struct tomoyo_execve *ee;
> -				struct file *file;
>  			case TOMOYO_SYMLINK_TARGET:
>  				symlink =3D obj ? obj->symlink_target : NULL;
>  				if (!symlink ||
> diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
> index badffc8271c8..8e2bb36df37b 100644
> --- a/security/tomoyo/util.c
> +++ b/security/tomoyo/util.c
> @@ -668,6 +668,8 @@ static bool tomoyo_file_matches_pattern2(const =
char *filename,
>  {
>  	while (filename < filename_end && pattern < pattern_end) {
>  		char c;
> +		int i, j;
> +
>  		if (*pattern !=3D '\\') {
>  			if (*filename++ !=3D *pattern++)
>  				return false;
> @@ -676,8 +678,6 @@ static bool tomoyo_file_matches_pattern2(const =
char *filename,
>  		c =3D *filename;
>  		pattern++;
>  		switch (*pattern) {
> -			int i;
> -			int j;
>  		case '?':
>  			if (c =3D=3D '/') {
>  				return false;
> --
> 2.17.1
