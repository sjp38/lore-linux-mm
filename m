Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C31146B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 13:24:04 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p7FHO1R9001556
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:24:01 -0700
Received: from qyk9 (qyk9.prod.google.com [10.241.83.137])
	by wpaz24.hot.corp.google.com with ESMTP id p7FHMWXO001901
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:24:00 -0700
Received: by qyk9 with SMTP id 9so3620104qyk.6
        for <linux-mm@kvack.org>; Mon, 15 Aug 2011 10:24:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110815150348.GC6597@quack.suse.cz>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
	<1313189245-7197-2-git-send-email-curtw@google.com>
	<20110815150348.GC6597@quack.suse.cz>
Date: Mon, 15 Aug 2011 10:24:00 -0700
Message-ID: <CAO81RMbe=ht0H_Ut9ybATKZFV7KFDBP8oT1_ZHz-Ve87gcvq2A@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi Jan:

On Mon, Aug 15, 2011 at 8:03 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 12-08-11 15:47:25, Curt Wohlgemuth wrote:
>> Add a new file, /proc/writeback/stats, which displays
>> machine global data for how many pages were cleaned for
>> which reasons. =A0It also displays some additional counts for
>> various writeback events.
>>
>> These data are also available for each BDI, in
>> /sys/block/<device>/bdi/writeback_stats .
> =A0I think /sys/kernel/debug/bdi/<device>/writeback_stats might be a bett=
er
> place since we don't really want to make a stable interface out of this,
> do we?

Okay, I was waiting for someone to request this, I'll change it.

>> Sample output:
>>
>> =A0 =A0page: balance_dirty_pages =A0 =A0 =A0 =A0 =A0 2561544
>> =A0 =A0page: background_writeout =A0 =A0 =A0 =A0 =A0 =A0 =A05153
>> =A0 =A0page: try_to_free_pages =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0page: sync =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A00
>> =A0 =A0page: kupdate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01027=
23
>> =A0 =A0page: fdatawrite =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01228779
>> =A0 =A0page: laptop_periodic =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
>> =A0 =A0page: free_more_memory =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
>> =A0 =A0page: fs_free_space =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0
> =A0The above stats are probably useful. I'm not so convinced about the st=
ats
> below - it looks like it should be simple enough to get them by enabling
> some trace points and processing output (or if we are missing some
> tracepoints, it would be worthwhile to add them).

For these specifically, I'd agree with you.  In general, though, I
think that having generally available aggregated stats is really
useful, in a different way than tracepoints are.

>
>> =A0 =A0periodic writeback =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0377
>> =A0 =A0single inode wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 0
>> =A0 =A0writeback_wb wait =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 1
>>
>> Signed-off-by: Curt Wohlgemuth <curtw@google.com>
> ...
>> +static size_t writeback_stats_to_str(struct writeback_stats *stats,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *=
buf, size_t len)
>> +{
>> + =A0 =A0 int bufsize =3D len - 1;
>> + =A0 =A0 int i, printed =3D 0;
>> + =A0 =A0 for (i =3D 0; i < WB_STAT_MAX; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 const char *label =3D wb_stats_labels[i];
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (label =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 printed +=3D snprintf(buf + printed, bufsize -=
 printed,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%-32s %10llu\=
n", label, stats->stats[i]);
> =A0Cast stats->stats[i] to unsigned long long explicitely since it doesn'=
t
> have to be u64...

Thanks.

>> + =A0 =A0 =A0 =A0 =A0 =A0 if (printed >=3D bufsize) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[len - 1] =3D '\n';
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +
>> + =A0 =A0 buf[printed - 1] =3D '\n';
>> + =A0 =A0 return printed;
>> +}
>> +
>> +static int writeback_seq_show(struct seq_file *m, void *data)
>> +{
>> + =A0 =A0 char *buf;
>> + =A0 =A0 size_t size;
>> + =A0 =A0 switch ((enum writeback_op)m->private) {
>> + =A0 =A0 case WB_STATS_OP:
> =A0What's the point of WB_STATS_OP?

It's a vestige of the many more files under /proc/writeback/ that we
have in our kernels (see my response to Fengguang's email) -- and so
processing each file is done via a different WB_xxx_OP.  I forgot to
simplify this in the patch I sent out; will fix this.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 size =3D seq_get_buf(m, &buf);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (size =3D=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 size =3D writeback_stats_print(writeback_sys_s=
tats, buf, size);
>> + =A0 =A0 =A0 =A0 =A0 =A0 seq_commit(m, size);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static int writeback_open(struct inode *inode, struct file *file)
>> +{
>> + =A0 =A0 return single_open(file, writeback_seq_show, PDE(inode)->data)=
;
>> +}
>> +
>> +static const struct file_operations writeback_ops =3D {
>> + =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D writeback_open,
>> + =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
>> + =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
>> + =A0 =A0 .release =A0 =A0 =A0 =A0=3D single_release,
>> +};
>> +
>> +
>> +void __init proc_writeback_init(void)
>> +{
>> + =A0 =A0 struct proc_dir_entry *base_dir;
>> + =A0 =A0 base_dir =3D proc_mkdir("writeback", NULL);
>> + =A0 =A0 if (base_dir =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "Creating /proc/writeback/ fai=
led");
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 writeback_sys_stats =3D alloc_percpu(struct writeback_stats);
>> +
>> + =A0 =A0 proc_create_data("stats", S_IRUGO|S_IWUSR, base_dir,
> =A0Can user really write to the file?

No to this file, I'll fix, thanks.  (Yes to some of our
/proc/writeback/ files, to clear them.)

Thanks,
Curt

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &writeback_ops, (void *)WB_STA=
TS_OP);
>> +}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
