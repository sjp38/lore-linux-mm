Subject: Re: [PATCH] aic7xxx parallel build
From: John Cherry <cherry@osdl.org>
In-Reply-To: <20040122174458.0bdf5f26.akpm@osdl.org>
References: <1074800332.29125.55.camel@cherrypit.pdx.osdl.net>
	 <1251588112.1074819190@aslan.btc.adaptec.com>
	 <1074819272.15610.2.camel@cherrypit.pdx.osdl.net>
	 <1074819903.15610.6.camel@cherrypit.pdx.osdl.net>
	 <20040122174458.0bdf5f26.akpm@osdl.org>
Content-Type: multipart/mixed; boundary="=-QuwPm3LeyGRKTbQJzfGI"
Message-Id: <1074887283.4537.15.camel@cherrytest.pdx.osdl.net>
Mime-Version: 1.0
Date: Fri, 23 Jan 2004 11:48:03 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Justin T. Gibbs" <gibbs@scsiguy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-QuwPm3LeyGRKTbQJzfGI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Andrew,

We are settled this time.  This patch fixes the aic7xxx parallel build
problem.  It was generated against 2.6.2-rc1-mm2.  It has passed the
compile regressions that were failing.

John

On Thu, 2004-01-22 at 17:44, Andrew Morton wrote:
> John Cherry <cherry@osdl.org> wrote:
> >
> > Can we get these changes back into Andrew's conduit?
> 
> Please send me a fresh patch when it's settled.

--=-QuwPm3LeyGRKTbQJzfGI
Content-Disposition: attachment; filename=patch.aic7xxx_Makefiles
Content-Type: text/x-makefile; name=patch.aic7xxx_Makefiles; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- linux-2.6.2-rc1-mm2/drivers/scsi/aic7xxx/Makefile	2004-01-20 19:50:41.000000000 -0800
+++ new/drivers/scsi/aic7xxx/Makefile	2004-01-22 16:57:32.000000000 -0800
@@ -1,7 +1,7 @@
 #
 # Makefile for the Linux aic7xxx SCSI driver.
 #
-# $Id: //depot/linux-aic79xx-2.5.0/drivers/scsi/aic7xxx/Makefile#7 $
+# $Id: //depot/linux-aic79xx-2.5.0/drivers/scsi/aic7xxx/Makefile#8 $
 #
 
 # Let kbuild descend into aicasm when cleaning
@@ -61,6 +58,13 @@ aicasm-7xxx-opts-$(CONFIG_AIC7XXX_REG_PR
 	-p $(obj)/aic7xxx_reg_print.c -i aic7xxx_osm.h
 
 ifeq ($(CONFIG_AIC7XXX_BUILD_FIRMWARE),y)
+# Create a dependency chain in generated files
+# to avoid concurrent invocations of the single
+# rule that builds them all.
+aic7xxx_seq.h: aic7xxx_reg.h
+ifeq ($(CONFIG_AIC7XXX_REG_PRETTY_PRINT),y)
+aic7xxx_reg.h: aic7xxx_reg_print.c
+endif
 $(aic7xxx-gen-y): $(src)/aic7xxx.seq $(src)/aic7xxx.reg $(obj)/aicasm/aicasm
 	$(obj)/aicasm/aicasm -I$(src) -r $(obj)/aic7xxx_reg.h \
 			      $(aicasm-7xxx-opts-y) -o $(obj)/aic7xxx_seq.h \
@@ -75,6 +79,13 @@ aicasm-79xx-opts-$(CONFIG_AIC79XX_REG_PR
 	-p $(obj)/aic79xx_reg_print.c -i aic79xx_osm.h
 
 ifeq ($(CONFIG_AIC79XX_BUILD_FIRMWARE),y)
+# Create a dependency chain in generated files
+# to avoid concurrent invocations of the single
+# rule that builds them all.
+aic79xx_seq.h: aic79xx_reg.h
+ifeq ($(CONFIG_AIC79XX_REG_PRETTY_PRINT),y)
+aic79xx_reg.h: aic79xx_reg_print.c
+endif
 $(aic79xx-gen-y): $(src)/aic79xx.seq $(src)/aic79xx.reg $(obj)/aicasm/aicasm
 	$(obj)/aicasm/aicasm -I$(src) -r $(obj)/aic79xx_reg.h \
 			      $(aicasm-79xx-opts-y) -o $(obj)/aic79xx_seq.h \
--- linux-2.6.2-rc1-mm2/drivers/scsi/aic7xxx/aicasm/Makefile	2004-01-20 19:50:31.000000000 -0800
+++ new/drivers/scsi/aic7xxx/aicasm/Makefile	2004-01-22 16:58:22.000000000 -0800
@@ -49,11 +49,19 @@ aicdb.h:
 clean:
 	rm -f $(clean-files)
 
+# Create a dependency chain in generated files
+# to avoid concurrent invocations of the single
+# rule that builds them all.
+aicasm_gram.c: aicasm_gram.h
 aicasm_gram.c aicasm_gram.h: aicasm_gram.y
 	$(YACC) $(YFLAGS) -b $(<:.y=) $<
 	mv $(<:.y=).tab.c $(<:.y=.c)
 	mv $(<:.y=).tab.h $(<:.y=.h)
 
+# Create a dependency chain in generated files
+# to avoid concurrent invocations of the single
+# rule that builds them all.
+aicasm_macro_gram.c: aicasm_macro_gram.h
 aicasm_macro_gram.c aicasm_macro_gram.h: aicasm_macro_gram.y
 	$(YACC) $(YFLAGS) -b $(<:.y=) -p mm $<
 	mv $(<:.y=).tab.c $(<:.y=.c)

--=-QuwPm3LeyGRKTbQJzfGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
