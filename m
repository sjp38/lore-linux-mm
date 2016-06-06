Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5683B6B0260
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:01:47 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id l39so95783438qgd.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:01:47 -0700 (PDT)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id z131si4979934ywb.154.2016.06.06.13.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:01:46 -0700 (PDT)
Received: by mail-yw0-x231.google.com with SMTP id o16so150649206ywd.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:01:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160606195228.GA27327@mwanda>
References: <20160606195228.GA27327@mwanda>
From: Thomas Garnier <thgarnie@google.com>
Date: Mon, 6 Jun 2016 13:01:45 -0700
Message-ID: <CAJcbSZEcW8u2Mx0awZO_8g38pnSAYfPR8e37oBEDPvFZQWv_fQ@mail.gmail.com>
Subject: Re: mm: reorganize SLAB freelist randomization
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>

No, the for loop is correct. Fisher-Yates shuffles algorithm is as follow:

-- To shuffle an array a of n elements (indices 0..n-1):
for i from n=E2=88=921 downto 1 do
     j random integer such that 0 <=3D j <=3D i
     exchange a[j] and a[i]

https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle

On Mon, Jun 6, 2016 at 12:52 PM, Dan Carpenter <dan.carpenter@oracle.com> w=
rote:
> Hello Thomas Garnier,
>
> The patch aded650eb82e: "mm: reorganize SLAB freelist randomization"
> from Jun 5, 2016, leads to the following static checker warning:
>
>         mm/slab_common.c:1160 freelist_randomize()
>         warn: why is zero skipped 'i'
>
> mm/slab_common.c
>   1146  /* Randomize a generic freelist */
>   1147  static void freelist_randomize(struct rnd_state *state, unsigned =
int *list,
>   1148                          size_t count)
>   1149  {
>   1150          size_t i;
>   1151          unsigned int rand;
>   1152
>   1153          for (i =3D 0; i < count; i++)
>   1154                  list[i] =3D i;
>   1155
>   1156          /* Fisher-Yates shuffle */
>   1157          for (i =3D count - 1; i > 0; i--) {
>
> This looks like it should be i >=3D 0.
>
>   1158                  rand =3D prandom_u32_state(state);
>   1159                  rand %=3D (i + 1);
>   1160                  swap(list[i], list[rand]);
>   1161          }
>   1162  }
>
> regards,
> dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
