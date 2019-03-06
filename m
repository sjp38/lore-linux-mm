Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D98F0C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:45:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 607FC20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:45:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CoaW0qNz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 607FC20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B29B58E0003; Wed,  6 Mar 2019 05:45:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD77D8E0002; Wed,  6 Mar 2019 05:45:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A07F8E0003; Wed,  6 Mar 2019 05:45:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4545F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 05:45:42 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id x15so2088107wmc.1
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 02:45:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:mime-version:subject
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=aL12gokwnY/RlIfz3R2182VWDKZfCIP367EeuUje6XU=;
        b=XOkEq+YeGwo1K17DxiqWtuQzuXRR1OyxS/S2wHVzVABB9lp29orop/e4xKjtVhmjVU
         anb7nekiKk7yHRQKdKHqjRxfeuZNkcEJJZ5GOeitdXK0SUTUZi78LCJSWG8kcDe5UKxc
         cF/SfxmIAbUOL2+LHGMuv2P2q7sW9zVLW5VQZLWWuUWJglfeL6zDmWK6XzK4wF9egPLv
         1DY1EFwanW9sPHIjx5WAV0xHOl2JHp3cK0YbGGgbMb4yIH7inYMW46OML89LLn2zW5Jj
         0WorB55HIs5MhROG7pLlzHS4FteT0xT6U1Bp/ZY537SIAtIEvbHfR83SF+i0pZanBZqJ
         y6Vg==
X-Gm-Message-State: APjAAAUQLjGK32MRprEyGlkAgvG3XL4UDGuDNudsTTYz7g08PnjQ1j3G
	se3z+vcuCxbxWzbsYIf1lhYW125VDsaMja3vfKagnri7gB2DTmnN8JYJmgKyXxFI0tGpyKHyHrI
	spcV5YjtYB+QsRg9Z+dlLCu3CMGwCuSxHljYh/73DQWnldmD3fpwxqfyZ09ZyIDr489jMuM1emS
	kae9MeZcYbNL3MJwOrrwEg1hauv83Qk2qnr9wTIV/rU7kCoQa/ijGIRkf1MWtbH5QDLhUrQxHSe
	hLnaiB5DvFFVwY9JPJagyAj35bwpvWJMHELctUfewW3WsaXwczfJGs23XT71FXX8LrwamRGkNhv
	jMU/iskuTVRslYBk1xxenl8quwIHv1F40oT4tGXxbVNmj29kCE7PQc6E7oVflrwBMXljRX654UB
	P
X-Received: by 2002:adf:822d:: with SMTP id 42mr2424232wrb.63.1551869141553;
        Wed, 06 Mar 2019 02:45:41 -0800 (PST)
X-Received: by 2002:adf:822d:: with SMTP id 42mr2424173wrb.63.1551869140294;
        Wed, 06 Mar 2019 02:45:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551869140; cv=none;
        d=google.com; s=arc-20160816;
        b=s+toQZLvYJ1uuG2I/CaY089XVV7TP6rBbFgeFR+cG9/nVodmGcSqkOD+qk+MSJnGsD
         T0KLiIdqUGiSpEK5xEGum9ZYOPXObzZCgHENXJFJEuOenkcWudfpm0ZQQMjLNC8RJI2I
         rYhInMH4IgnIlqGRXlrziHpjEriIQVxp36JFNPOKT9aCJftdMiLHzw0zGPQm8Vn2ltOF
         O5kEIMFqJ+JfnLlyfuoy6mea9mrGlb6kHXg4ZXXTM9FF4WcPRpIbcYepUgKaqMTziIJe
         i4IV+H4sGiVUKlnKdqzvS6/U+2+acp8qyRQcl4sN+5RS3xuLpG3HSqfSi67B+VZtSWGj
         el7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:subject:mime-version:from:dkim-signature;
        bh=aL12gokwnY/RlIfz3R2182VWDKZfCIP367EeuUje6XU=;
        b=lTsLyVOXsRhz7VvPLBmAv1LTE9fy9/a2osOhHzK7LDjnmnrdUUcgQNNyDf47iOmac/
         ql2RXmxGinb5NRgx6FfXmnU6Ok01tE2x5JBWOB4AK9z+fXst74eGHEabNGk+elOWSCXa
         i89fiYUYWN4D2JkgGABLl9cg1+uPDx1tqeTtf4GAoRg3yEgscGriGchir7TI9bJPVndh
         z+/8gb3TPffXcP2fFMOcJ8z7YZbn1IdCS4H5525fel/uoa2m+6I+2etviuhYqz+qcyBB
         34d7ze1wAPB3E7yYbKxz++H6oYXVbvz63MeIv6Q5/8tMmnOzmLjt5Z8PyBReRJo4jIaa
         u87Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CoaW0qNz;
       spf=pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=christophe.de.dinechin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor936699wre.15.2019.03.06.02.45.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 02:45:40 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=CoaW0qNz;
       spf=pass (google.com: domain of christophe.de.dinechin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=christophe.de.dinechin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:mime-version:subject:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=aL12gokwnY/RlIfz3R2182VWDKZfCIP367EeuUje6XU=;
        b=CoaW0qNzUzWMxtN+jbfpFdWcWmQCowIfDQGfekSPODQHE2p3I9F4NW3h0s7Ts7v+Iy
         cwnkqMVgswcZkgEdMsGSj64lgIy1wYpg+Q5ImfTzgEy5nG46CJYYAkEFXCSRVECJePRf
         T9wvXMcRwn+x1VotNd+9Z6P1XUNw3T94XGiKNGaUL2rgyC6ZBPduRDONjvv2Susgu+g6
         myLVfE5lWVPOn60YWBjLndmTzlckHvtr8j/6n6+OWKmkP4TLRGM4o4lU8mqkg1Rb7Yc2
         ztQ7Bn6DuJN30Qv1QoVg46fOKPsiANRB5x62phFbh5f64rBk19MsRAMKw/v7yvKj9Yc5
         FWKA==
X-Google-Smtp-Source: APXvYqx9zua042qRfe/GPv/TKmGCWyH5EI/UCpAzDDgLxcfBW1J6XhJ/fKaDqLjv2S1JmNx1nzz0Ug==
X-Received: by 2002:adf:f70c:: with SMTP id r12mr2671333wrp.54.1551869139488;
        Wed, 06 Mar 2019 02:45:39 -0800 (PST)
Received: from [192.168.77.22] (val06-1-88-182-161-34.fbx.proxad.net. [88.182.161.34])
        by smtp.gmail.com with ESMTPSA id z8sm1027945wmi.28.2019.03.06.02.45.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 02:45:38 -0800 (PST)
From: Christophe de Dinechin <christophe.de.dinechin@gmail.com>
X-Google-Original-From: Christophe de Dinechin <christophe@dinechin.org>
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC PATCH V2 2/5] vhost: fine grain userspace memory accessors
In-Reply-To: <1551856692-3384-3-git-send-email-jasowang@redhat.com>
Date: Wed, 6 Mar 2019 11:45:31 +0100
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 KVM list <kvm@vger.kernel.org>,
 "open list:VIRTIO GPU DRIVER" <virtualization@lists.linux-foundation.org>,
 netdev@vger.kernel.org,
 open list <linux-kernel@vger.kernel.org>,
 Peter Xu <peterx@redhat.com>,
 linux-mm@kvack.org,
 aarcange@redhat.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <4C1386C5-F153-43DD-8B14-CC752FA5A07A@dinechin.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-3-git-send-email-jasowang@redhat.com>
To: Jason Wang <jasowang@redhat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 6 Mar 2019, at 08:18, Jason Wang <jasowang@redhat.com> wrote:
>=20
> This is used to hide the metadata address from virtqueue helpers. This
> will allow to implement a vmap based fast accessing to metadata.
>=20
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> drivers/vhost/vhost.c | 94 =
+++++++++++++++++++++++++++++++++++++++++----------
> 1 file changed, 77 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 400aa78..29709e7 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -869,6 +869,34 @@ static inline void __user =
*__vhost_get_user(struct vhost_virtqueue *vq,
> 	ret; \
> })
>=20
> +static inline int vhost_put_avail_event(struct vhost_virtqueue *vq)
> +{
> +	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->avail_idx),
> +			      vhost_avail_event(vq));
> +}
> +
> +static inline int vhost_put_used(struct vhost_virtqueue *vq,
> +				 struct vring_used_elem *head, int idx,
> +				 int count)
> +{
> +	return vhost_copy_to_user(vq, vq->used->ring + idx, head,
> +				  count * sizeof(*head));
> +}
> +
> +static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
> +
> +{
> +	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->used_flags),
> +			      &vq->used->flags);
> +}
> +
> +static inline int vhost_put_used_idx(struct vhost_virtqueue *vq)
> +
> +{
> +	return vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
> +			      &vq->used->idx);
> +}
> +
> #define vhost_get_user(vq, x, ptr, type)		\
> ({ \
> 	int ret; \
> @@ -907,6 +935,43 @@ static void vhost_dev_unlock_vqs(struct vhost_dev =
*d)
> 		mutex_unlock(&d->vqs[i]->mutex);
> }
>=20
> +static inline int vhost_get_avail_idx(struct vhost_virtqueue *vq,
> +				      __virtio16 *idx)
> +{
> +	return vhost_get_avail(vq, *idx, &vq->avail->idx);
> +}
> +
> +static inline int vhost_get_avail_head(struct vhost_virtqueue *vq,
> +				       __virtio16 *head, int idx)
> +{
> +	return vhost_get_avail(vq, *head,
> +			       &vq->avail->ring[idx & (vq->num - 1)]);
> +}
> +
> +static inline int vhost_get_avail_flags(struct vhost_virtqueue *vq,
> +					__virtio16 *flags)
> +{
> +	return vhost_get_avail(vq, *flags, &vq->avail->flags);
> +}
> +
> +static inline int vhost_get_used_event(struct vhost_virtqueue *vq,
> +				       __virtio16 *event)
> +{
> +	return vhost_get_avail(vq, *event, vhost_used_event(vq));
> +}
> +
> +static inline int vhost_get_used_idx(struct vhost_virtqueue *vq,
> +				     __virtio16 *idx)
> +{
> +	return vhost_get_used(vq, *idx, &vq->used->idx);
> +}
> +
> +static inline int vhost_get_desc(struct vhost_virtqueue *vq,
> +				 struct vring_desc *desc, int idx)
> +{
> +	return vhost_copy_from_user(vq, desc, vq->desc + idx, =
sizeof(*desc));
> +}
> +
> static int vhost_new_umem_range(struct vhost_umem *umem,
> 				u64 start, u64 size, u64 end,
> 				u64 userspace_addr, int perm)
> @@ -1840,8 +1905,7 @@ int vhost_log_write(struct vhost_virtqueue *vq, =
struct vhost_log *log,
> static int vhost_update_used_flags(struct vhost_virtqueue *vq)
> {
> 	void __user *used;
> -	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->used_flags),
> -			   &vq->used->flags) < 0)
> +	if (vhost_put_used_flags(vq))
> 		return -EFAULT;
> 	if (unlikely(vq->log_used)) {
> 		/* Make sure the flag is seen before log. */
> @@ -1858,8 +1922,7 @@ static int vhost_update_used_flags(struct =
vhost_virtqueue *vq)
>=20
> static int vhost_update_avail_event(struct vhost_virtqueue *vq, u16 =
avail_event)
> {
> -	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->avail_idx),
> -			   vhost_avail_event(vq)))
> +	if (vhost_put_avail_event(vq))
> 		return -EFAULT;
> 	if (unlikely(vq->log_used)) {
> 		void __user *used;
> @@ -1895,7 +1958,7 @@ int vhost_vq_init_access(struct vhost_virtqueue =
*vq)
> 		r =3D -EFAULT;
> 		goto err;
> 	}
> -	r =3D vhost_get_used(vq, last_used_idx, &vq->used->idx);
> +	r =3D vhost_get_used_idx(vq, &last_used_idx);
> 	if (r) {
> 		vq_err(vq, "Can't access used idx at %p\n",
> 		       &vq->used->idx);

=46rom the error case, it looks like you are not entirely encapsulating
knowledge of what the accessor uses, i.e. it=E2=80=99s not:

		vq_err(vq, "Can't access used idx at %p\n",
		       &last_user_idx);

Maybe move error message within accessor?

> @@ -2094,7 +2157,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue =
*vq,
> 	last_avail_idx =3D vq->last_avail_idx;
>=20
> 	if (vq->avail_idx =3D=3D vq->last_avail_idx) {
> -		if (unlikely(vhost_get_avail(vq, avail_idx, =
&vq->avail->idx))) {
> +		if (unlikely(vhost_get_avail_idx(vq, &avail_idx))) {
> 			vq_err(vq, "Failed to access avail idx at %p\n",
> 				&vq->avail->idx);
> 			return -EFAULT;

Same here.

> @@ -2121,8 +2184,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue =
*vq,
>=20
> 	/* Grab the next descriptor number they're advertising, and =
increment
> 	 * the index we've seen. */
> -	if (unlikely(vhost_get_avail(vq, ring_head,
> -		     &vq->avail->ring[last_avail_idx & (vq->num - 1)]))) =
{
> +	if (unlikely(vhost_get_avail_head(vq, &ring_head, =
last_avail_idx))) {
> 		vq_err(vq, "Failed to read head: idx %d address %p\n",
> 		       last_avail_idx,
> 		       &vq->avail->ring[last_avail_idx % vq->num]);
> @@ -2157,8 +2219,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue =
*vq,
> 			       i, vq->num, head);
> 			return -EINVAL;
> 		}
> -		ret =3D vhost_copy_from_user(vq, &desc, vq->desc + i,
> -					   sizeof desc);
> +		ret =3D vhost_get_desc(vq, &desc, i);
> 		if (unlikely(ret)) {
> 			vq_err(vq, "Failed to get descriptor: idx %d =
addr %p\n",
> 			       i, vq->desc + i);
> @@ -2251,7 +2312,7 @@ static int __vhost_add_used_n(struct =
vhost_virtqueue *vq,
>=20
> 	start =3D vq->last_used_idx & (vq->num - 1);
> 	used =3D vq->used->ring + start;
> -	if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
> +	if (vhost_put_used(vq, heads, start, count)) {
> 		vq_err(vq, "Failed to write used");
> 		return -EFAULT;
> 	}
> @@ -2293,8 +2354,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, =
struct vring_used_elem *heads,
>=20
> 	/* Make sure buffer is written before we update index. */
> 	smp_wmb();
> -	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
> -			   &vq->used->idx)) {
> +	if (vhost_put_used_idx(vq)) {
> 		vq_err(vq, "Failed to increment used idx");
> 		return -EFAULT;
> 	}
> @@ -2327,7 +2387,7 @@ static bool vhost_notify(struct vhost_dev *dev, =
struct vhost_virtqueue *vq)
>=20
> 	if (!vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX)) {
> 		__virtio16 flags;
> -		if (vhost_get_avail(vq, flags, &vq->avail->flags)) {
> +		if (vhost_get_avail_flags(vq, &flags)) {
> 			vq_err(vq, "Failed to get flags");
> 			return true;
> 		}
> @@ -2341,7 +2401,7 @@ static bool vhost_notify(struct vhost_dev *dev, =
struct vhost_virtqueue *vq)
> 	if (unlikely(!v))
> 		return true;
>=20
> -	if (vhost_get_avail(vq, event, vhost_used_event(vq))) {
> +	if (vhost_get_used_event(vq, &event)) {
> 		vq_err(vq, "Failed to get used event idx");
> 		return true;
> 	}
> @@ -2386,7 +2446,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, =
struct vhost_virtqueue *vq)
> 	if (vq->avail_idx !=3D vq->last_avail_idx)
> 		return false;
>=20
> -	r =3D vhost_get_avail(vq, avail_idx, &vq->avail->idx);
> +	r =3D vhost_get_avail_idx(vq, &avail_idx);
> 	if (unlikely(r))
> 		return false;
> 	vq->avail_idx =3D vhost16_to_cpu(vq, avail_idx);
> @@ -2422,7 +2482,7 @@ bool vhost_enable_notify(struct vhost_dev *dev, =
struct vhost_virtqueue *vq)
> 	/* They could have slipped one in as we were doing that: make
> 	 * sure it's written, then check again. */
> 	smp_mb();
> -	r =3D vhost_get_avail(vq, avail_idx, &vq->avail->idx);
> +	r =3D vhost_get_avail_idx(vq, &avail_idx);
> 	if (r) {
> 		vq_err(vq, "Failed to check avail idx at %p: %d\n",
> 		       &vq->avail->idx, r);
> --=20
> 1.8.3.1
>=20

