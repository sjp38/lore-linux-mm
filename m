Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B57916B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 05:40:03 -0500 (EST)
Received: by qam2 with SMTP id 2so1215767qam.14
        for <linux-mm@kvack.org>; Mon, 28 Nov 2011 02:40:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322474116.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321866845.3831.7.camel@lappy>
	<1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111128181446.2ab784d0@kryten>
	<1322474116.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Date: Mon, 28 Nov 2011 12:40:01 +0200
Message-ID: <CAEnQRZBxjCUByhEb3TfZEwVxkGY-uDKYr_Yavfr+TLx-TPoxrA@mail.gmail.com>
Subject: Re: [PATCH] net: Fix corruption in /proc/*/net/dev_mcast
From: Daniel Baluta <dbaluta@ixiacom.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, Anton Blanchard <anton@samba.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Mihai Maruseac <mmaruseac@ixiacom.com>

>> dev_mc_seq_ops uses dev_seq_start/next/stop but only allocates
>> sizeof(struct seq_net_private) of private data, whereas it expects
>> sizeof(struct dev_iter_state):
>>
>> struct dev_iter_state {
>> =A0 =A0 =A0 struct seq_net_private p;
>> =A0 =A0 =A0 unsigned int pos; /* bucket << BUCKET_SPACE + offset */
>> };
>>
>> Create dev_seq_open_ops and use it so we don't have to expose
>> struct dev_iter_state.

Good catch, indeed! We've now checked and this is the only place
where the problem happens.


>> +int dev_seq_open_ops(struct inode *inode, struct file *file,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct seq_operations *ops)
>> +{
>> + =A0 =A0 return seq_open_net(inode, file, ops, sizeof(struct dev_iter_s=
tate));
>> +}

Perhaps you could use this function also in dev_seq_open (dev.c:4280).

>> =A0static int dev_mc_seq_open(struct inode *inode, struct file *file)
>> =A0{
>> - =A0 =A0 return seq_open_net(inode, file, &dev_mc_seq_ops,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seq_net_=
private));
>> + =A0 =A0 return dev_seq_open_ops(inode, file, &dev_mc_seq_ops);
>> =A0}
>>
>> =A0static const struct file_operations dev_mc_seq_fops =3D {


thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
