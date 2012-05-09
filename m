Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 598EA6B00F5
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:07:19 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so384198bkc.0
        for <linux-mm@kvack.org>; Wed, 09 May 2012 07:07:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3f7a217a08fd2c508576cbac8d26b017.squirrel@www.codeaurora.org>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-15-git-send-email-svenkatr@ti.com> <3f7a217a08fd2c508576cbac8d26b017.squirrel@www.codeaurora.org>
From: "S, Venkatraman" <svenkatr@ti.com>
Date: Wed, 9 May 2012 19:36:57 +0530
Message-ID: <CANfBPZ-ZAJjDcy6cR7q+n7SKGc+2dMYfFREg-6ovh+E1eNbGWg@mail.gmail.com>
Subject: Re: [PATCH v2 14/16] mmc: block: Implement HPI invocation and
 handling logic.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kdorfman@codeaurora.org
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Wed, May 9, 2012 at 2:05 PM,  <kdorfman@codeaurora.org> wrote:
>
>> +static bool mmc_can_do_foreground_hpi(struct mmc_queue *mq,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct request *req, unsigned =
int thpi)
>> +{
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If some time has elapsed since the issuing of previous wr=
ite
>> + =A0 =A0 =A0* command, or if the size of the request was too small, the=
re's
>> + =A0 =A0 =A0* no point in preempting it. Check if it's worthwhile to pr=
eempt
>> + =A0 =A0 =A0*/
>> + =A0 =A0 int time_elapsed =3D jiffies_to_msecs(jiffies -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mq->mqrq_cur->mmc_active.mrq->=
cmd->started_time);
>> +
>> + =A0 =A0 if (time_elapsed <=3D thpi)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> Some host controllers (or DMA) has possibility to get the byte count of
> current transaction. It may be implemented as host api (similar to abort
> ops). Then you have more accurate estimation of worthiness.
>

Byte count returned by DMA or the HC doesn't mean that the data has
actually been
burnt into the device (due to internal buffering). This is one of the
reasons for
defining the CORRECTLY_PRG_SECTORS_NUM register in the standard which
can be queried to find how much was correctly written.
 Unfortunately it can only be queried after the abort has been issued.

>> +
>> + =A0 =A0 return false;
>> +}
>
> Thanks, Kostya
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
